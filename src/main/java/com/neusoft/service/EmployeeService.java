package com.neusoft.service;

import java.util.List;

import com.neusoft.po.Employee;

public interface EmployeeService {
	public List<Employee> getAll() throws Exception;
	public void saveEmp(Employee employee) throws Exception;
	public boolean checkUser(String empName) throws Exception;
	public Employee getEmp(Integer id) throws Exception;
	public void editEmp(Employee employee) throws Exception;
	public void deleteEmp(Integer id) throws Exception;
	public void deleteEmps(List<Integer> idList) throws Exception; 
}
