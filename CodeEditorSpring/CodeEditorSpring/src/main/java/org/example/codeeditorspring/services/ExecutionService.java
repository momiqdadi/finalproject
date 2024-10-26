package org.example.codeeditorspring.services;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

@Service
@Slf4j
public class ExecutionService {
    private final String RESOURCE_PATH = "src/main/resources/CDN/";

    public String execute(String fileName) {
        String filePath = RESOURCE_PATH + fileName;
        StringBuilder result = new StringBuilder();
        try {
            Process compiledProcess = compile(filePath);
            read(compiledProcess, result);

            int compileExitCode = compiledProcess.waitFor();
            if (compileExitCode != 0) {
                System.out.println("Compilation failed with exit code: " + compileExitCode);
                read(compiledProcess, result);
                return result.toString();
            }
            System.out.println("Compilation successful!");

            Process runProcess = run(filePath);

            read(runProcess, result);

            int runExitCode = runProcess.waitFor();
            System.out.println("Program exited with code: " + runExitCode);

        } catch (IOException e) {
            log.error(e.getMessage());
        } catch (InterruptedException e) {
            log.error(e.getMessage());
        }
        return result.toString();
    }

    private Process compile(String filePath) throws IOException {
        ProcessBuilder compileProcessBuilder = new ProcessBuilder("javac", filePath);
        return compileProcessBuilder.start();
    }

    private Process run(String filePath) throws IOException {
        ProcessBuilder runProcessBuilder = new ProcessBuilder("java", filePath);
        return runProcessBuilder.start();
    }

    private void read(Process compiledProcess, StringBuilder str) throws IOException {
        BufferedReader errorReader = new BufferedReader(new InputStreamReader(compiledProcess.getErrorStream()));
        String line;
        while ((line = errorReader.readLine()) != null) {
            str.append(line).append("\n");
        }

        BufferedReader outputReader = new BufferedReader(new InputStreamReader(compiledProcess.getInputStream()));
        while ((line = outputReader.readLine()) != null) {
            str.append(line).append("\n");
        }
    }

}
