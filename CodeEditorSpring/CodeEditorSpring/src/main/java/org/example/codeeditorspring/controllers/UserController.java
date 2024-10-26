package org.example.codeeditorspring.controllers;

import lombok.extern.slf4j.Slf4j;
import org.example.codeeditorspring.entities.User;
import org.example.codeeditorspring.entities.UserFile;
import org.example.codeeditorspring.repositories.FileJpa;
import org.example.codeeditorspring.repositories.UserJpa;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("user")
public class UserController {
    private UserJpa userJpa;
    private FileJpa fileJpa;

    @Autowired
    public UserController(UserJpa userJpa, FileJpa fileJpa) {
        this.userJpa = userJpa;
        this.fileJpa = fileJpa;
    }

    @PostMapping
    public User createUser(@RequestParam String email) {
        return userJpa.save(new User(email));
    }

    @PostMapping("/add_file")
    public UserFile addFile(@RequestParam String email, @RequestParam String fileName) {
        String[] path = fileName.split("/");
        String folder = path[0];
        String file = path[1];
        return fileJpa.save(new UserFile(null, folder, file, email));
    }

    @GetMapping("/get_files")
    public List<String> getFiles(@RequestParam String email, @RequestParam String folder) {
        return fileJpa.findByUserEmailAndFolder(email, folder).stream().map(userFile -> userFile.getFile()).toList();
    }

    @GetMapping("get_folders")
    public List<String> getFolders(@RequestParam String email) {
        return fileJpa.findByUserEmail(email).stream().map(userFile -> userFile.getFolder()).toList();
    }
}
