package com.neusoft.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.neusoft.po.Employee;
import com.neusoft.po.Message;
import com.neusoft.service.EmployeeService;

@Controller
public class EmployeeController {
	@Autowired
	private EmployeeService employeeService;
	/*@RequestMapping("/emps")
	public String getEmployees(@RequestParam(defaultValue="1") Integer curPage, Model model) throws Exception {
		PageHelper.startPage(curPage, 5);
		List<Employee> emps = employeeService.getAll();
		PageInfo<Employee> pageInfo=new PageInfo<>(emps, 5);
		model.addAttribute("pageInfo", pageInfo);
		return "list";
	}*/
	@ResponseBody
	@RequestMapping("/emps")
	public Message getEmployeesWithJson(@RequestParam(defaultValue="1") Integer curPage) throws Exception{
		PageHelper.startPage(curPage, 5);
		List<Employee> emps = employeeService.getAll();
		PageInfo<Employee> pageInfo=new PageInfo<>(emps, 5);
		return Message.success().add("pageInfo", pageInfo);
	}
	@ResponseBody
	@RequestMapping(value="/emp", method= {RequestMethod.POST})
	public Message addEmp(@Valid Employee employee, BindingResult result) throws Exception {
		if(result.hasErrors()) {
			Map<String, Object> map=new HashMap<>();
			List<FieldError> fieldErrors = result.getFieldErrors();
			for (FieldError fieldError : fieldErrors) {
				map.put(fieldError.getField(), fieldError.getDefaultMessage());
			}
			return Message.fail().add("errorFields", map);
		}else {
			employeeService.saveEmp(employee);
			return Message.success();
		}
	}
	@ResponseBody
	@RequestMapping("/userExists")
	public Message userExists(String empName) throws Exception {
		String regex="(^[a-zA-Z0-9_-]{6,16}$)|(^[\\u2E80-\\u9FFF]{2,5}$)";
		if(!empName.matches(regex)) {
			return Message.fail().add("va_msg", "用户名可以是6-16位英文和数字的组合或者2-5位的中文");
		}
		boolean checkUser = employeeService.checkUser(empName);
		if(checkUser) {
			return Message.success();
		}else {
			return Message.fail().add("va_msg", "用户名不可用");
		}
	}
	@ResponseBody
	@RequestMapping(value="/emp/{id}", method= {RequestMethod.GET})
	public Message getEmp(@PathVariable("id") Integer id) throws Exception {
		Employee employee = employeeService.getEmp(id);
		return Message.success().add("emp", employee);
	}
	@ResponseBody
	@RequestMapping(value="/emp/{empId}", method= {RequestMethod.PUT})
	public Message updateEmp(Employee employee) throws Exception {
		employeeService.editEmp(employee);
		return Message.success();
	}
	@ResponseBody
	@RequestMapping(value="/emp/{ids}", method= {RequestMethod.DELETE})
	public Message deleteEmp(@PathVariable("ids") String ids) throws Exception {
		if(ids.contains("-")) {
			String[] idStrs = ids.split("-");
			List<Integer> idList=new ArrayList<>();
			for (String str : idStrs) {
				idList.add(Integer.parseInt(str));
			}
			employeeService.deleteEmps(idList);
		}else {
			Integer id=Integer.parseInt(ids);
			employeeService.deleteEmp(id);
		}
		return Message.success();
	}
}
