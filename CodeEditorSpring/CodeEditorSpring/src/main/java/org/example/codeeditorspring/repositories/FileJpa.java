package org.example.codeeditorspring.repositories;

import org.example.codeeditorspring.entities.UserFile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FileJpa extends JpaRepository<UserFile, Long> {
    @Query("SELECT DISTINCT uf FROM UserFile uf WHERE uf.email = :email")
    List<UserFile> findByUserEmail(String email);
    @Query("SELECT DISTINCT uf FROM UserFile uf WHERE uf.email = :email and uf.folder = :folder")
    List<UserFile> findByUserEmailAndFolder(String email, String folder);
}
