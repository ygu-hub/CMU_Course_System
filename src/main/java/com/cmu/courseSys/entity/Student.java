package com.cmu.courseSys.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.io.Serializable;

@Data
public class Student implements Serializable {
    @TableId
    private String andrewId;
    private String password;
    private int status;
    private int residencyStatus;
    private String advisorName;
}
