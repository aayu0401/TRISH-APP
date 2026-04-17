package com.trish.service;

import com.trish.model.Photo;
import com.trish.model.User;
import com.trish.repository.PhotoRepository;
import com.trish.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PhotoRepository photoRepository;

    @Value("${file.upload-dir:uploads/photos}")
    private String uploadDir;

    public User getUserById(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
    }

    @Transactional
    public User updateProfile(Long userId, User updates) {
        User user = getUserById(userId);

        if (updates.getName() != null) {
            user.setName(updates.getName());
        }
        if (updates.getBio() != null) {
            user.setBio(updates.getBio());
        }
        if (updates.getInterests() != null) {
            user.setInterests(updates.getInterests());
        }
        if (updates.getCity() != null) {
            user.setCity(updates.getCity());
        }
        if (updates.getCountry() != null) {
            user.setCountry(updates.getCountry());
        }

        return userRepository.save(user);
    }

    @Transactional
    public User updateLocation(Long userId, Double latitude, Double longitude) {
        User user = getUserById(userId);
        user.setLatitude(latitude);
        user.setLongitude(longitude);
        return userRepository.save(user);
    }

    @Transactional
    public User updatePreferences(Long userId, User.Gender interestedInGender, Integer minAge, Integer maxAge,
            Integer maxDistance) {
        User user = getUserById(userId);

        if (interestedInGender != null) {
            user.setInterestedInGender(interestedInGender);
        }
        if (minAge != null && minAge >= 18) {
            user.setMinAge(minAge);
        }
        if (maxAge != null && maxAge <= 100) {
            user.setMaxAge(maxAge);
        }
        if (maxDistance != null && maxDistance > 0) {
            user.setMaxDistance(maxDistance);
        }

        return userRepository.save(user);
    }

    @Transactional
    public Photo uploadPhoto(Long userId, MultipartFile file) throws IOException {
        User user = getUserById(userId);

        // Check photo limit (max 6 photos)
        long photoCount = photoRepository.countByUserId(userId);
        if (photoCount >= 6) {
            throw new IllegalArgumentException("Maximum 6 photos allowed");
        }

        // Validate file type
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("Only image files are allowed");
        }

        // Create upload directory if it doesn't exist
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Generate unique filename
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename != null && originalFilename.contains(".")
                ? originalFilename.substring(originalFilename.lastIndexOf("."))
                : ".jpg";
        String filename = UUID.randomUUID().toString() + extension;

        // Save file
        Path filePath = uploadPath.resolve(filename);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        // Create photo record
        Photo photo = new Photo();
        photo.setUser(user);
        photo.setUrl("/uploads/photos/" + filename);
        photo.setDisplayOrder((int) photoCount);

        return photoRepository.save(photo);
    }

    @Transactional
    public void deletePhoto(Long userId, Long photoId) {
        Photo photo = photoRepository.findById(photoId)
                .orElseThrow(() -> new IllegalArgumentException("Photo not found"));

        if (!photo.getUser().getId().equals(userId)) {
            throw new IllegalArgumentException("Unauthorized to delete this photo");
        }

        // Delete file from filesystem
        try {
            Path filePath = Paths.get(photo.getUrl().substring(1)); // Remove leading /
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            // Log error but continue with database deletion
        }

        photoRepository.delete(photo);
    }

    public List<Photo> getUserPhotos(Long userId) {
        return photoRepository.findByUserIdOrderByDisplayOrderAsc(userId);
    }

    @Transactional
    public User updatePassport(Long userId, Boolean active, Double lat, Double lon, String city, String country) {
        User user = getUserById(userId);
        if (!user.getIsPremium()) {
            throw new IllegalArgumentException("Passport is a premium feature");
        }
        user.setIsPassportActive(active);
        if (active) {
            user.setPassportLatitude(lat);
            user.setPassportLongitude(lon);
            user.setPassportCity(city);
            user.setPassportCountry(country);
        }
        return userRepository.save(user);
    }

    @Transactional
    public User activateBoost(Long userId) {
        User user = getUserById(userId);
        if (!user.getIsPremium()) {
            throw new IllegalArgumentException("Boost is a premium feature");
        }
        user.setIsBoosted(true);
        user.setBoostExpiresAt(LocalDateTime.now().plusMinutes(30)); // 30 minute boost
        return userRepository.save(user);
    }
}
