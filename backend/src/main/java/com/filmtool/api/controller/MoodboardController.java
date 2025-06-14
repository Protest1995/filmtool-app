package com.filmtool.api.controller;

import com.filmtool.api.model.Moodboard;
import com.filmtool.api.repository.MoodboardRepository;
import com.filmtool.api.repository.ImageRepository;
import com.filmtool.api.service.FileStorageService;
import com.filmtool.api.model.Image;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

@RestController
@RequestMapping("/api/moodboards")
public class MoodboardController {

    @Autowired
    private MoodboardRepository moodboardRepository;

    @Autowired
    private ImageRepository imageRepository;

    @Autowired
    private FileStorageService fileStorageService;

    @GetMapping
    public List<Moodboard> getAllMoodboards() {
        return moodboardRepository.findAll();
    }

    @PostMapping
    public Moodboard createMoodboard(@RequestBody Moodboard moodboard) {
        return moodboardRepository.save(moodboard);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Moodboard> getMoodboardById(@PathVariable(value = "id") Long moodboardId) {
        Moodboard moodboard = moodboardRepository.findById(moodboardId)
                .orElseThrow(() -> new RuntimeException("Moodboard not found with id " + moodboardId));
        return ResponseEntity.ok(moodboard);
    }

    @PostMapping("/{id}/uploadCoverImage")
    public ResponseEntity<Moodboard> uploadCoverImage(@PathVariable(value = "id") Long moodboardId,
                                                 @RequestParam("file") MultipartFile file) {
        return moodboardRepository.findById(moodboardId).map(moodboard -> {
            String fileName = fileStorageService.storeFile(file);
            String imageUrl = "/uploads/" + fileName;
            moodboard.setCoverImageUrl(imageUrl);
            Moodboard updatedMoodboard = moodboardRepository.save(moodboard);
            return ResponseEntity.ok(updatedMoodboard);
        }).orElse(ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    @PostMapping("/{id}/images")
    public ResponseEntity<Image> addImageToMoodboard(@PathVariable(value = "id") Long moodboardId,
                                                      @RequestParam("file") MultipartFile file) {
        return moodboardRepository.findById(moodboardId).map(moodboard -> {
            String fileName = fileStorageService.storeFile(file);
            String imageUrl = "/uploads/" + fileName;

            Image image = new Image(imageUrl, moodboard);
            Image savedImage = imageRepository.save(image);

            return ResponseEntity.ok(savedImage);
        }).orElse(ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    // We will add more endpoints for updating, and deleting moodboards later.
} 