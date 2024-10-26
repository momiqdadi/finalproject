package org.example.codeeditorspring.repositories;

import org.example.codeeditorspring.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserJpa extends JpaRepository<User, Long> {
}
