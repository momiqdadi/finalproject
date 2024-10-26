package org.example.codeeditorspring.services;

import lombok.RequiredArgsConstructor;
import org.example.codeeditorspring.entities.User;
import org.example.codeeditorspring.repositories.FileJpa;
import org.example.codeeditorspring.repositories.FileSystemRepository;
import org.example.codeeditorspring.repositories.UserJpa;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FileSystemService {
    private final FileSystemRepository fileSystemRepository;
    private final String RESOURCE_PATH = "src/main/resources/CDN/";
    private final UserJpa userJpa;
    private final FileJpa fileJpa;

    //TODO: createFolder()
    public void createFolder(String folderName) throws IOException {
        Path path = Paths.get(RESOURCE_PATH + folderName);
        fileSystemRepository.createFolder(path);
    }

    //TODO: retrieveFolders
    public ArrayList<String> readFolder(String fileName) throws IOException {
        String path = RESOURCE_PATH + fileName;
        return fileSystemRepository
                .readAllFolders(path)
                .map(Path::getFileName)
                .map(Path::toString)
                .collect(Collectors.toCollection(ArrayList::new));
    }

    //TODO: createFile()
    public String create(String filename) {
        String filePath = RESOURCE_PATH + filename;
        Path path = Paths.get(filePath);
        fileSystemRepository.create(path);

        return filename;
    }

    //TODO: deleteFile()
    public void delete(String filename) throws IOException {
        Path filePath = Paths.get(RESOURCE_PATH + filename + ".java");
        fileSystemRepository.delete(filePath);
    }

    //TODO: updateFile()
    public void update(String filename, String content) throws IOException {
        Path filePath = Paths.get(RESOURCE_PATH + filename);
        fileSystemRepository.update(filePath, content);
    }

    //TODO: retrieveFile()
    public String read(String fileName) throws IOException {
        Path filePath = Paths.get(RESOURCE_PATH + fileName);
        return fileSystemRepository.read(filePath);
    }
}
