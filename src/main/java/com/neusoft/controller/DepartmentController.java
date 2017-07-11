package com.neusoft.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.neusoft.po.Department;
import com.neusoft.po.Message;
import com.neusoft.service.DepartmentService;

@Controller
public class DepartmentController {
	@Autowired
	private DepartmentService departmentService;
	@ResponseBody
	@RequestMapping("/depts")
	public Message getDepts() throws Exception {
		List<Department> depts = departmentService.getAll();
		return Message.success().add("depts", depts);
	}
}
