package com.cmu.courseSys.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cmu.courseSys.entity.Student;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Component;

@Mapper
public interface StudentMapper extends BaseMapper<Student> {
}
