package com.neusoft.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.neusoft.mapper.EmployeeMapper;
import com.neusoft.po.Employee;
import com.neusoft.po.EmployeeExample;
import com.neusoft.po.EmployeeExample.Criteria;
import com.neusoft.service.EmployeeService;

@Service
public class EmployeeServiceImpl implements EmployeeService {
	@Autowired
	private EmployeeMapper employeeMapper;
	@Override
	public List<Employee> getAll() throws Exception {
		return employeeMapper.selectByExampleWithDept(null);
	}
	@Override
	public void saveEmp(Employee employee) throws Exception {
		employeeMapper.insertSelective(employee);
	}
	@Override
	public boolean checkUser(String empName) throws Exception {
		EmployeeExample example=new EmployeeExample();
		Criteria criteria = example.createCriteria();
		criteria.andEmpNameEqualTo(empName);
		long count = employeeMapper.countByExample(example);
		return count == 0;
	}
	@Override
	public Employee getEmp(Integer id) throws Exception {
		return employeeMapper.selectByPrimaryKey(id);
	}
	@Override
	public void editEmp(Employee employee) throws Exception {
		employeeMapper.updateByPrimaryKeySelective(employee);
	}
	@Override
	public void deleteEmp(Integer id) throws Exception {
		employeeMapper.deleteByPrimaryKey(id);
	}
	@Override
	public void deleteEmps(List<Integer> idList) throws Exception {
		EmployeeExample example=new EmployeeExample();
		Criteria criteria = example.createCriteria();
		criteria.andEmpIdIn(idList);
		employeeMapper.deleteByExample(example);
	}

}
