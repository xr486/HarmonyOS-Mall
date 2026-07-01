
package com.hongmen.mall.repository;

import com.hongmen.mall.entity.Address;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 收货地址仓库
 */
@Repository
public interface AddressRepository extends JpaRepository<Address, String> {
    List<Address> findByUserId(String userId);
    Optional<Address> findByUserIdAndIsDefaultTrue(String userId);
}
