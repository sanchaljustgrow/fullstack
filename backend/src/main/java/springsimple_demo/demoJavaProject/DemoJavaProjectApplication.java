package springsimple_demo.demoJavaProject;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController // Add this to make it a web controller
public class DemoJavaProjectApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoJavaProjectApplication.class, args);
        System.out.println("Hello, World!  this is sanchal java project");
    }

    @GetMapping("/") // Add this to map the root URL
    public String home() {
        return "Hello, World! this is sanchal java project from the web!";
    }
}
