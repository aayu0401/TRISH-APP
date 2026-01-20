package com.trish.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.CommonsRequestLoggingFilter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Configuration
public class RateLimitConfig {

    @Bean
    public RateLimitFilter rateLimitFilter() {
        return new RateLimitFilter();
    }

    @Bean
    public CommonsRequestLoggingFilter requestLoggingFilter() {
        CommonsRequestLoggingFilter loggingFilter = new CommonsRequestLoggingFilter();
        loggingFilter.setIncludeClientInfo(true);
        loggingFilter.setIncludeQueryString(true);
        loggingFilter.setIncludePayload(false);
        loggingFilter.setMaxPayloadLength(10000);
        return loggingFilter;
    }

    public static class RateLimitFilter implements Filter {
        private static final int MAX_REQUESTS_PER_MINUTE = 100;
        private static final long TIME_WINDOW_MS = 60000; // 1 minute

        private final Map<String, RequestCounter> requestCounts = new ConcurrentHashMap<>();

        @Override
        public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
                throws IOException, ServletException {
            
            HttpServletRequest httpRequest = (HttpServletRequest) request;
            HttpServletResponse httpResponse = (HttpServletResponse) response;
            
            String clientIp = getClientIP(httpRequest);
            
            // Skip rate limiting for health check
            if (httpRequest.getRequestURI().contains("/api/health")) {
                chain.doFilter(request, response);
                return;
            }

            RequestCounter counter = requestCounts.computeIfAbsent(clientIp, k -> new RequestCounter());
            
            synchronized (counter) {
                long currentTime = System.currentTimeMillis();
                
                // Reset counter if time window has passed
                if (currentTime - counter.windowStart > TIME_WINDOW_MS) {
                    counter.count = 0;
                    counter.windowStart = currentTime;
                }
                
                counter.count++;
                
                if (counter.count > MAX_REQUESTS_PER_MINUTE) {
                    httpResponse.setStatus(429); // Too Many Requests
                    httpResponse.getWriter().write("{\"error\":\"Rate limit exceeded. Please try again later.\"}");
                    httpResponse.setContentType("application/json");
                    return;
                }
            }
            
            chain.doFilter(request, response);
        }

        private String getClientIP(HttpServletRequest request) {
            String xfHeader = request.getHeader("X-Forwarded-For");
            if (xfHeader == null) {
                return request.getRemoteAddr();
            }
            return xfHeader.split(",")[0];
        }

        private static class RequestCounter {
            long windowStart = System.currentTimeMillis();
            int count = 0;
        }
    }
}
