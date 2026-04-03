package com.example.demo.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Configures Spring Boot to serve the React SPA.
 * All routes NOT starting with /api or /admin fall through to index.html,
 * so React Router handles client-side navigation correctly.
 */
@Configuration
public class SpaWebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/static/**")
                .addResourceLocations("classpath:/static/static/");
        registry.addResourceHandler("/**")
                .addResourceLocations("classpath:/static/");
    }

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        // Forward these React Router paths to index.html
        registry.addViewController("/register").setViewName("forward:/index.html");
        registry.addViewController("/customerhome").setViewName("forward:/index.html");
        registry.addViewController("/UserCartPage").setViewName("forward:/index.html");
        registry.addViewController("/orders").setViewName("forward:/index.html");
        registry.addViewController("/admin").setViewName("forward:/index.html");
        registry.addViewController("/admindashboard").setViewName("forward:/index.html");
    }
}
