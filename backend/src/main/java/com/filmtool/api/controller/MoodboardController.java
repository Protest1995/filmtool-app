package com.filmtool.api.controller;

import com.filmtool.api.model.Moodboard;
import com.filmtool.api.repository.MoodboardRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/moodboards")
public class MoodboardController {

    @Autowired
    private MoodboardRepository moodboardRepository;

    @GetMapping
    public List<Moodboard> getAllMoodboards() {
        return moodboardRepository.findAll();
    }

    @PostMapping
    public Moodboard createMoodboard(@RequestBody Moodboard moodboard) {
        return moodboardRepository.save(moodboard);
    }

    // We will add more endpoints for updating, and deleting moodboards later.
} 