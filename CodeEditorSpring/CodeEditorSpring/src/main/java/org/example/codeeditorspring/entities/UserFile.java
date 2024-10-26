package org.example.codeeditorspring.entities;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "UserFile")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class UserFile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String folder;
    private String file;


    @Column(name = "user_email")
    private String email;
}
