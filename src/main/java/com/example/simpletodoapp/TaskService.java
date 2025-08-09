package com.example.simpletodoapp;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
@Service
public class TaskService {
    @Autowired
    private TaskRepository taskRepository;
    public List<Task> findAll() { return taskRepository.findAll(); }
    public Task save(Task task) { return taskRepository.save(task); }
    public void deleteById(Long id) { taskRepository.deleteById(id); }
}