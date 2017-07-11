package com.neusoft.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.neusoft.mapper.DepartmentMapper;
import com.neusoft.po.Department;
import com.neusoft.service.DepartmentService;

@Service
public class DepartmentServiceImpl implements DepartmentService{
	@Autowired
	private DepartmentMapper departmentMapper;
	@Override
	public List<Department> getAll() throws Exception {
		return departmentMapper.selectByExample(null);
	}
	
}
