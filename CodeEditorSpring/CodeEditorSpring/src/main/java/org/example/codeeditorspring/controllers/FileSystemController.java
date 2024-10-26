package org.example.codeeditorspring.controllers;

import lombok.RequiredArgsConstructor;
import org.example.codeeditorspring.services.FileSystemService;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping
@RequiredArgsConstructor
public class FileSystemController {
    private final FileSystemService fileSystemService;

    @PostMapping("folder")
    public void createFolder(@RequestBody String folderName) throws IOException {
        fileSystemService.createFolder(folderName);
    }

    @GetMapping("folder")
    public List<String> getAllFolders(@RequestParam String folderName) throws IOException {
        return fileSystemService.readFolder(folderName);
    }

    //TODO: createFile()
    @PostMapping("files")
    public String createFile(@RequestBody String fileName) {
        return fileSystemService.create(fileName);
    }

    //TODO: retrieveFile()
    @GetMapping("files")
    public String read(@RequestParam String fileName) throws IOException {
        return fileSystemService.read(fileName);
    }

    //TODO: deleteFile()
    @DeleteMapping("files")
    public void delete(@RequestParam String fileName) throws IOException {
        fileSystemService.delete(fileName);
    }

    //TODO: updateFile()
    @PutMapping("files")
    public void update(@RequestParam String fileName, @RequestParam String content) throws IOException {
        fileSystemService.update(fileName, content);
    }
}
