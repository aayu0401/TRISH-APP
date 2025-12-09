package com.trish.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "personality_profiles")
@Data
public class PersonalityProfile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    private String mbtiType;

    private String enneagramType;

    @ElementCollection
    @CollectionTable(name = "personality_traits", joinColumns = @JoinColumn(name = "profile_id"))
    @Column(name = "trait")
    private List<String> traits;

    private Integer opennessScore;

    private Integer conscientiousnessScore;

    private Integer extraversionScore;

    private Integer agreeablenessScore;

    private Integer neuroticismScore;

    @Column(length = 2000)
    private String bio;

    @ElementCollection
    @CollectionTable(name = "personality_values", joinColumns = @JoinColumn(name = "profile_id"))
    @Column(name = "value")
    private List<String> values;

    @ElementCollection
    @CollectionTable(name = "personality_interests", joinColumns = @JoinColumn(name = "profile_id"))
    @Column(name = "interest")
    private List<String> interests;

    private Boolean testCompleted = false;

    private LocalDateTime testCompletedAt;

    @Column(updatedAt = "CURRENT_TIMESTAMP", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(updatedAt = "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP", insertable = false, updatable = false)
    private LocalDateTime updatedAt;
}
