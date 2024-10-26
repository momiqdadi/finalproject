package org.example.codeeditorspring.controllers;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.codeeditorspring.services.ExecutionService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Slf4j
@AllArgsConstructor
@RequestMapping
public class ExecutionController {
    private final ExecutionService executionService;

    @GetMapping("/execute")
    public String execute(@RequestParam String path) {
        return executionService.execute(path);
    }
}
