package com.filmtool.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig {

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**") // Only allow CORS for our API endpoints
                        .allowedOrigins("*")   // Allow all origins
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // Allowed methods
                        .allowedHeaders("*");  // Allow all headers
            }
        };
    }
} 