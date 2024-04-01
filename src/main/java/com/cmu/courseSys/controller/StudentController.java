package com.cmu.courseSys.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.cmu.courseSys.common.R;
import com.cmu.courseSys.entity.Student;
import com.cmu.courseSys.service.StudentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.util.DigestUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;

@Slf4j
@RestController
@RequestMapping("/student")
public class StudentController {

    @Autowired
    private StudentService studentService;

    /**
     * Student Login
     */
    @PostMapping("/login")
    public R<Student> login(HttpServletRequest request, @RequestBody Student student){
        String password = student.getPassword();
        // md5 encrypt the input password
        password = DigestUtils.md5DigestAsHex(password.getBytes());
        String andrewId = student.getAndrewId();
        R<Student> matchStudent = studentService.login(andrewId, password);
        log.info("match Student result: " + matchStudent.toString());
        // check if the R<student> result belongs to an error(0)
        if(matchStudent.getCode() == 0){
            return matchStudent;
        }

        // if login successfully, store the andrewId into Session, and return targetStudent result.
        request.getSession().setAttribute("student", andrewId);
        return matchStudent;
    }

    /**
     * Student Logout
     */
    @PostMapping("/logout")
    public R<String> logout(HttpServletRequest request) {
        // clean Session
        request.getSession().removeAttribute("student");
        return R.success("Exit successfully!");
    }


}
