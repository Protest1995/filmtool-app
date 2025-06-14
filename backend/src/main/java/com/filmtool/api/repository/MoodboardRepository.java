package com.filmtool.api.repository;

import com.filmtool.api.model.Moodboard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MoodboardRepository extends JpaRepository<Moodboard, Long> {
    // We can add custom query methods here later if needed.
} 