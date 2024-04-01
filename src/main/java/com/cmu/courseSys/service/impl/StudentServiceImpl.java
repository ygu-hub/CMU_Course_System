package com.cmu.courseSys.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cmu.courseSys.common.R;
import com.cmu.courseSys.entity.Student;
import com.cmu.courseSys.mapper.StudentMapper;
import com.cmu.courseSys.service.StudentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.DigestUtils;
@Slf4j
@Service
public class StudentServiceImpl extends ServiceImpl<StudentMapper, Student> implements StudentService {
    @Override
    public R<Student> login(String andrewId, String password){
        password = DigestUtils.md5DigestAsHex(password.getBytes());

        LambdaQueryWrapper<Student> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Student::getAndrewId, andrewId);
        Student matchStudent = this.getOne(queryWrapper);

        // check if the student exists in database
        if(matchStudent == null){
            log.error("Student " + andrewId + " does not exist in CMU system.");
            return R.error("Student " + andrewId + " does not exist in CMU system.");
        }

        // check if the student password is correct
        if(!matchStudent.getPassword().equals(password)){
            log.error("Incorrect password! Expected: " + matchStudent.getPassword() + " Actual: " + password);
            return R.error("Incorrect password!");
        }

        // check if the student status is locked(0)
        if(matchStudent.getStatus() == 0){
            log.error("Student " + andrewId + " is banned in CMU system.");
            return R.error("Student " + andrewId + " is banned in CMU system.");
        }

        // student can login successfully
        log.info("successfully login!");
        return R.success(matchStudent);
    }
}
