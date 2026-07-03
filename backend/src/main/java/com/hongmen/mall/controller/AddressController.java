package com.hongmen.mall.controller;

import com.hongmen.mall.common.Result;
import com.hongmen.mall.entity.Address;
import com.hongmen.mall.repository.AddressRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

/**
 * 收货地址控制器
 */
@RestController
@RequestMapping("/api/v1/addresses")
@RequiredArgsConstructor
public class AddressController {

    private final AddressRepository addressRepository;

    private String getUserId(HttpServletRequest request) {
        return (String) request.getAttribute("userId");
    }

    @GetMapping
    public Result<List<Address>> listAddresses(HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");
        return Result.success(addressRepository.findByUserId(userId));
    }

    @PostMapping
    public Result<Address> addAddress(@RequestBody Address address, HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        address.setAddressId(UUID.randomUUID().toString());
        address.setUserId(userId);
        long now = System.currentTimeMillis();
        address.setCreatedAt(now);
        address.setUpdatedAt(now);

        if (Boolean.TRUE.equals(address.getIsDefault())) {
            addressRepository.findByUserIdAndIsDefaultTrue(userId).ifPresent(a -> {
                a.setIsDefault(false);
                addressRepository.save(a);
            });
        }

        return Result.success(addressRepository.save(address));
    }

    @PutMapping("/{id}")
    public Result<Address> updateAddress(@PathVariable String id, @RequestBody Address update,
                                         HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        return addressRepository.findById(id).map(addr -> {
            if (!addr.getUserId().equals(userId)) {
                return Result.<Address>error(403, "无权限修改");
            }
            if (update.getName() != null) addr.setName(update.getName());
            if (update.getPhone() != null) addr.setPhone(update.getPhone());
            if (update.getProvince() != null) addr.setProvince(update.getProvince());
            if (update.getCity() != null) addr.setCity(update.getCity());
            if (update.getDistrict() != null) addr.setDistrict(update.getDistrict());
            if (update.getDetail() != null) addr.setDetail(update.getDetail());
            if (update.getIsDefault() != null && update.getIsDefault()) {
                addressRepository.findByUserIdAndIsDefaultTrue(userId).ifPresent(a -> {
                    a.setIsDefault(false);
                    addressRepository.save(a);
                });
            }
            addr.setIsDefault(update.getIsDefault());
            if (update.getIsDefault() == null) addr.setIsDefault(false);
            addr.setUpdatedAt(System.currentTimeMillis());
            addressRepository.save(addr);
            return Result.success(addr);
        }).orElse(Result.error(404, "地址不存在"));
    }

    @DeleteMapping("/{id}")
    public Result<String> deleteAddress(@PathVariable String id, HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        return addressRepository.findById(id).map(addr -> {
            if (!addr.getUserId().equals(userId)) {
                return Result.<String>error(403, "无权限删除");
            }
            addressRepository.delete(addr);
            return Result.success("删除成功");
        }).orElse(Result.error(404, "地址不存在"));
    }

    @PutMapping("/{id}/default")
    public Result<Address> setDefault(@PathVariable String id, HttpServletRequest request) {
        String userId = getUserId(request);
        if (userId == null) return Result.error(401, "未登录");

        return addressRepository.findById(id).map(addr -> {
            if (!addr.getUserId().equals(userId)) {
                return Result.<Address>error(403, "无权限操作");
            }
            addressRepository.findByUserIdAndIsDefaultTrue(userId).ifPresent(a -> {
                a.setIsDefault(false);
                addressRepository.save(a);
            });
            addr.setIsDefault(true);
            addr.setUpdatedAt(System.currentTimeMillis());
            addressRepository.save(addr);
            return Result.success(addr);
        }).orElse(Result.error(404, "地址不存在"));
    }
}
