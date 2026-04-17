package com.trish.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "users")
@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    @JsonIgnore
    private String password;

    @Column(nullable = false)
    private String name;

    @Column(length = 500)
    private String bio;

    @Column(nullable = false)
    private LocalDate dateOfBirth;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Gender gender;

    @Column
    private Double latitude;

    @Column
    private Double longitude;

    @Column
    private String city;

    @Column
    private String country;

    @ElementCollection
    @CollectionTable(name = "user_interests", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "interest")
    private List<String> interests = new ArrayList<>();

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("displayOrder ASC")
    private List<Photo> photos = new ArrayList<>();

    // Preferences
    @Enumerated(EnumType.STRING)
    private Gender interestedInGender;

    @Column
    private Integer minAge;

    @Column
    private Integer maxAge;

    @Column
    private Integer maxDistance; // in kilometers

    @Column(nullable = false)
    private Boolean isPremium = false;

    @Column(nullable = false)
    private Boolean isActive = true;

    @Column(nullable = false)
    private Boolean isVerified = false;

    @Column(nullable = false)
    private Boolean emailVerified = false;

    // Passport Feature
    @Column
    private Boolean isPassportActive = false;

    @Column
    private Double passportLatitude;

    @Column
    private Double passportLongitude;

    @Column
    private String passportCity;

    @Column
    private String passportCountry;

    // Advanced Filters
    @Column
    private String religion;

    @Column
    private String zodiacSign;

    @Column
    private Integer height; // in cm

    @Column
    private LocalDateTime boostExpiresAt;

    @Column
    private Boolean isBoosted = false;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    public enum Gender {
        MALE, FEMALE, NON_BINARY, OTHER
    }

    // Helper method to calculate age
    public int getAge() {
        return LocalDate.now().getYear() - dateOfBirth.getYear();
    }

    public boolean isActive() {
        return Boolean.TRUE.equals(isActive);
    }

    public void setActive(boolean active) {
        this.isActive = active;
    }

    public boolean isVerified() {
        return Boolean.TRUE.equals(isVerified);
    }

    public void setVerified(boolean verified) {
        this.isVerified = verified;
    }
}
