package com.trish.config;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class RestExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidation(
            MethodArgumentNotValidException ex,
            HttpServletRequest request
    ) {
        String message = "Validation failed";
        FieldError fieldError = ex.getBindingResult().getFieldError();
        if (fieldError != null && fieldError.getDefaultMessage() != null && !fieldError.getDefaultMessage().isBlank()) {
            message = fieldError.getDefaultMessage();
        }

        return ResponseEntity.badRequest().body(buildBody(
                message,
                "validation_error",
                request
        ));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, Object>> handleBadRequest(
            IllegalArgumentException ex,
            HttpServletRequest request
    ) {
        String message = ex.getMessage() != null && !ex.getMessage().isBlank() ? ex.getMessage() : "Bad request";
        return ResponseEntity.badRequest().body(buildBody(
                message,
                "bad_request",
                request
        ));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleUnexpected(
            Exception ex,
            HttpServletRequest request
    ) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(buildBody(
                "Internal server error",
                "internal_error",
                request
        ));
    }

    private Map<String, Object> buildBody(String message, String error, HttpServletRequest request) {
        Map<String, Object> body = new HashMap<>();
        body.put("message", message);
        body.put("error", error);
        body.put("path", request != null ? request.getRequestURI() : null);
        body.put("timestamp", Instant.now().toString());
        return body;
    }
}

