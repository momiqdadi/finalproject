package org.example.codeeditorspring.repositories;

import org.springframework.stereotype.Repository;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.stream.Stream;

@Repository
public class FileSystemRepository {
    //TODO: createFolder()
    public void createFolder(Path path) throws IOException {
        Files.createDirectories(path);
    }

    public Stream<Path> readAllFolders(String folderPath) throws IOException {
        return Files.list(Paths.get(folderPath));
    }

    //TODO: createFile()
    public void create(Path filename) {
        try {
            Files.createFile(filename);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    //TODO: deleteFile()
    public void delete(Path path) throws IOException {
        Files.delete(path);
    }

    //TODO: updateFile()
    public void update(Path path, String content) throws IOException {
        Files.write(path,
                content.getBytes(),
                StandardOpenOption.WRITE,
                StandardOpenOption.TRUNCATE_EXISTING,
                StandardOpenOption.CREATE);
    }

    //TODO: retrieveFile()
    public String read(Path path) throws IOException {
        return new String(Files.readAllBytes(path));
    }
}
