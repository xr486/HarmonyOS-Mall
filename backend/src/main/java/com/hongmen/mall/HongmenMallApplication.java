
package com.hongmen.mall;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class HongmenMallApplication {

    public static void main(String[] args) {
        SpringApplication.run(HongmenMallApplication.class, args);
    }

}
