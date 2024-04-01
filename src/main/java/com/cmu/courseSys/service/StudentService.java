package com.cmu.courseSys.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.cmu.courseSys.common.R;
import com.cmu.courseSys.entity.Student;
import org.springframework.web.bind.annotation.RequestBody;

import javax.servlet.http.HttpServletRequest;

public interface StudentService extends IService<Student> {
    R<Student> login(String andrewId, String password);
}
