package com.filmtool.api.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

@Entity
@Table(name = "images")
public class Image {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String imageUrl;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "moodboard_id", nullable = false)
    @JsonBackReference
    private Moodboard moodboard;

    // Constructors
    public Image() {
    }

    public Image(String imageUrl, Moodboard moodboard) {
        this.imageUrl = imageUrl;
        this.moodboard = moodboard;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Moodboard getMoodboard() {
        return moodboard;
    }

    public void setMoodboard(Moodboard moodboard) {
        this.moodboard = moodboard;
    }
} 