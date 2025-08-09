package com.example.simpletodoapp;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
@Controller
public class TaskController {
    @Autowired
    private TaskService taskService;
    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("tasks", taskService.findAll());
        model.addAttribute("newTask", new Task());
        return "index";
    }
    @PostMapping("/add")
    public String addTask(Task task) {
        taskService.save(task);
        return "redirect:/";
    }
    @GetMapping("/delete/{id}")
    public String deleteTask(@PathVariable Long id) {
        taskService.deleteById(id);
        return "redirect:/";
    }
}