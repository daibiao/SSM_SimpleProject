<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Employees List</title>
<link
	href="${pageContext.request.contextPath }/static/bootstrap-3.3.7-dist/css/bootstrap.min.css"
	rel="stylesheet">
<script
	src="${pageContext.request.contextPath }/static/jquery/jquery-3.2.1.js"></script>
<script
	src="${pageContext.request.contextPath }/static/bootstrap-3.3.7-dist/js/bootstrap.min.js"></script>
<script type="text/javascript">
	var totalRecord, currentPage;
	$(function() {
		to_page(1);
	});
	function to_page(curPage){
		
		$.ajax({
			type : "GET",
			url : "${pageContext.request.contextPath }/emps",
			data : "curPage="+curPage,
			success : function(result) {
				build_emps_table(result);
				build_page_info(result);
				build_page_nav(result);
			}
		});	
	}
	function build_emps_table(result) {
		$("#emps_table tbody").empty();
		var emps = result.extend.pageInfo.list;
		$(emps).each(function(index, emp) {
			var checkboxTd = $("<td><input type='checkbox' class='checkOne'/></td>");
			var empIdTd = $("<td></td>").append(emp.empId);
			var empNameTd = $("<td></td>").append(emp.empName);
			var gender = emp.gender == 'M' ? "男" : "女";
			var genderTd = $("<td></td>").append(gender);
			var emailTd = $("<td></td>").append(emp.email);
			var deptNameTd = $("<td></td>").append(emp.department.deptName);
			var editBtn = $("<button></button>").prop("type","button").addClass("btn btn-primary btn-xs edit_btn")
			.append($("<span></span>").addClass("glyphicon glyphicon-pencil"))
			.append(" edit");
			editBtn.attr("edit-id",emp.empId);
			var deleteBtn = $("<button></button>").prop("type","button").addClass("btn btn-danger btn-xs del_btn")
			.append($("<span></span>").addClass("glyphicon glyphicon-trash"))
			.append(" delete");
			deleteBtn.attr("del-id",emp.empId);
			var operationTd = $("<td></td>").append(editBtn).append(" ").append(deleteBtn);
			var tr=$("<tr></tr>").append(checkboxTd)
								 .append(empIdTd)
						  		 .append(empNameTd)
						         .append(genderTd)
						         .append(emailTd)
						         .append(deptNameTd)
						         .append(operationTd);
			$("#emps_table tbody").append(tr);
		});
	}
	function build_page_info(result) {
		$("#page_info_area").empty();
		$("#page_info_area").append("当前")
		.append($("<span></span>").addClass("label label-default").append(result.extend.pageInfo.pageNum))
		.append("页,总")
		.append($("<span></span>").addClass("label label-default").append(result.extend.pageInfo.pages))
		.append("页,总共")
		.append($("<span></span>").addClass("label label-default").append(result.extend.pageInfo.total))
		.append("条记录");
		totalRecord=result.extend.pageInfo.total;
		currentPage = result.extend.pageInfo.pageNum;
	}
	function build_page_nav(result) {
		$("#page_nav_area").empty();
		var ul = $("<ul></ul>").addClass("pagination");

		var firstPageLi = $("<li></li>").append($("<a></a>").append("首页").attr("href","#"));
		var prePageLi = $("<li></li>").append($("<a></a>").append("&laquo;"));
		if(result.extend.pageInfo.hasPreviousPage == false){
			firstPageLi.addClass("disabled");
			prePageLi.addClass("disabled");
		}else{
			firstPageLi.click(function(){
				to_page(1);
			});
			prePageLi.click(function(){
				to_page(result.extend.pageInfo.pageNum -1);
			});
		}
		
		var nextPageLi = $("<li></li>").append($("<a></a>").append("&raquo;"));
		var lastPageLi = $("<li></li>").append($("<a></a>").append("末页").attr("href","#"));
		if(result.extend.pageInfo.hasNextPage == false){
			nextPageLi.addClass("disabled");
			lastPageLi.addClass("disabled");
		}else{
			nextPageLi.click(function(){
				to_page(result.extend.pageInfo.pageNum +1);
			});
			lastPageLi.click(function(){
				to_page(result.extend.pageInfo.pages);
			});
		}
		
		ul.append(firstPageLi).append(prePageLi);
		
		$.each(result.extend.pageInfo.navigatepageNums,function(index,page){
			
			var numLi = $("<li></li>").append($("<a></a>").append(page));
			if(result.extend.pageInfo.pageNum == page){
				numLi.addClass("active");
			}
			numLi.click(function(){
				to_page(page);
			});
			ul.append(numLi);
		});
		ul.append(nextPageLi).append(lastPageLi);

		var navEle = $("<nav></nav>").append(ul);
		navEle.appendTo("#page_nav_area");
	}
	$(function(){
		$("#emp_add_modal_btn").click(function(){
			resetForm("#empAddModal form");
			getDepts("#empAddModal select");
			$("#empAddModal").modal({
				backdrop:"static"
			});
		});
		$("#empName_add_input").change(function(){
			var empName=$(this).val();
			$.ajax({
				type: "POST",
				url: "${pageContext.request.contextPath }/userExists",
				data: "empName="+empName,
				success: function(result){
					if(result.code==100){
						show_validate_msg("#empName_add_input","success","用户名可用");
						$("#emp_save_btn").attr("ajax-va","success");
					}else{
						show_validate_msg("#empName_add_input","error",result.extend.va_msg);
						$("#emp_save_btn").attr("ajax-va","error");
					}
				}
			});
		});
		$("#emp_save_btn").click(function(){
			if(!validate_add_form()){
				return false;
			}
			if($(this).attr("ajax-va")=="error"){
				return false;
			}
			$.ajax({
				type: "POST",
				url: "${pageContext.request.contextPath }/emp",
				data: $("#empAddModal form").serialize(),
				success: function(result){
					if(result.code == 100){
						$("#empAddModal").modal('hide');
						to_page(totalRecord);
						build_prompt_box();
					}else{
						if(undefined != result.extend.errorFields.email){
							show_validate_msg("#email_add_input", "error", result.extend.errorFields.email);
						}
						if(undefined != result.extend.errorFields.empName){
							show_validate_msg("#empName_add_input", "error", result.extend.errorFields.empName);
						}
					}
				}
			});
		});
		$(document).on("click",".edit_btn",function(){
			resetForm("#empUpdateModal form");
			getDepts("#empUpdateModal select");
			getEmp($(this).attr("edit-id"));
			$("#emp_update_btn").attr("edit-id",$(this).attr("edit-id"));
			$("#empUpdateModal").modal({
				backdrop:"static"
			});
		});
		$("#emp_update_btn").click(function(){
			var email=$("#email_update_input").val();
			var regEmail=/^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/;
			if(!regEmail.test(email)){
				show_validate_msg("#email_update_input","error","邮箱格式不正确");
				return false;
			}else{
				show_validate_msg("#email_update_input","success","");
			}
			$.ajax({
				type: "PUT",
				url: "${pageContext.request.contextPath }/emp/"+$(this).attr("edit-id"),
				data: $("#empUpdateModal form").serialize(),
				success: function(result){
					$("#empUpdateModal").modal('hide');
					to_page(currentPage);
					build_prompt_box();
				}
			});
		});
		$(document).on("click",".del_btn",function(){
			var empName=$(this).parents("tr").find("td:eq(2)").text();
			var empId=$(this).attr("del-id");
			if(confirm("are you sure delete the "+empName+"?")){
				$.ajax({
					type: "DELETE",
					url: "${pageContext.request.contextPath }/emp/"+empId,
					success: function(result){
						to_page(currentPage);
					}
				});
			}
		});
		$("#checkAll").click(function(){
			$(".checkOne").prop("checked",$(this).prop("checked"));
		});
		$(document).on("click",".checkOne",function(){
			var flag=$(".checkOne:checked").length == $(".checkOne").length;
				$("#checkAll").prop("checked",flag);
		});
		$("#emp_del_all_btn").click(function(){
			var empNames="";
			var idStr="";
			$.each($(".checkOne:checked"),function(){
				empNames += $(this).parents("tr").find("td:eq(2)").text()+",";
				idStr += $(this).parents("tr").find("td:eq(1)").text()+"-";
			});
			empNames=empNames.substring(0,empNames.length-1);
			idStr=idStr.substring(0,idStr.length-1);
			if(confirm("are you sure"+empNames+"?")){
				$.ajax({
					type: "DELETE",
					url: "${pageContext.request.contextPath }/emp/"+idStr,
					success: function(result){
						to_page(currentPage);
					}
				});
			}
		});
	});
	function getEmp(id){
		$.ajax({
			type: "GET",
			url: "${pageContext.request.contextPath }/emp/"+id,
			success: function(result){
				var emp=result.extend.emp;
				$("#empName_update_static").text(emp.empName);
				$("#email_update_input").val(emp.email);
				$("#empUpdateModal input[name=gender]").val([emp.gender]);
				$("#empUpdateModal select").val([emp.dId]);
			}
		});
	}
	function resetForm(ele){
		$(ele)[0].reset();
		$(ele).find("*").removeClass("has-error has-success");
		$(ele).find(".help-block").text("");
	}
	function getDepts(ele){
		$(ele).empty();
		$.ajax({
			type: "GET",
			url: "${pageContext.request.contextPath }/depts",
			success: function(result){
				//console.log(result);
				$.each(result.extend.depts,function(index,dept){
					var optionEle = $("<option></option>").append(dept.deptName).attr("value",dept.deptId);
					optionEle.appendTo(ele);
				});
			}
		});
	}
	function show_validate_msg(ele,status,msg){
		$(ele).parent().removeClass("has-success has-error");
		$(ele).next("span").text("");
		if("success"==status){
			$(ele).parent().addClass("has-success");
			$(ele).next("span").text(msg);
		}else if("error"==status){
			$(ele).parent().addClass("has-error");
			$(ele).next("span").text(msg);
		}
	}
	function validate_add_form(){
		var empName=$("#empName_add_input").val();
		var regName=/(^[a-zA-Z0-9_-]{6,16}$)|(^[\u2E80-\u9FFF]{2,5}$)/;
		if(!regName.test(empName)){
			show_validate_msg("#empName_add_input","error","用户名可以是6-16位英文和数字的组合或者2-5位的中文");
			return false;
		}else{
			show_validate_msg("#empName_add_input","success","");
		}
		var email=$("#email_add_input").val();
		var regEmail=/^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/;
		if(!regEmail.test(email)){
			show_validate_msg("#email_add_input","error","邮箱格式不正确");
			return false;
		}else{
			show_validate_msg("#email_add_input","success","");
		}
		return true;
	}
	function build_prompt_box(){
		var div=$("<div></div>").addClass("alert alert-success alert-dismissible").attr("role","alert")
						.append($("<button></button>").addClass("close").attr("data-dismiss","alert").attr("aria-label","close")
								.append($("<span></span>").attr("aria-hidden","true").append("&times;")))
								.append($("<strong></strong>").append("Well done!"))
								.append(" You successfully handle the data.");
		div.insertBefore(container);
	}
</script>
</head>
<body>
	<div class="modal fade" id="empAddModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
	        	<div class="modal-header">
	            	<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
	                <h4 class="modal-title" id="myModalLabel">employee add</h4>
	      		</div>
	      		<div class="modal-body">
	        		<form class="form-horizontal">
			  			<div class="form-group">
			    			<label class="col-sm-2 control-label">empName</label>
			    			<div class="col-sm-10">
			      				<input type="text" name="empName" class="form-control" id="empName_add_input" placeholder="例如'daibiao'">
			    				<span class="help-block"></span>
			    			</div>
			  			</div>
			  			<div class="form-group">
			    			<label class="col-sm-2 control-label">email</label>
			    			<div class="col-sm-10">
			      				<input type="text" name="email" class="form-control" id="email_add_input" placeholder="例如'dai_biao@163.com'">
			    				<span class="help-block"></span>
			    			</div>
			  			</div>
			  			<div class="form-group">
			    			<label class="col-sm-2 control-label">gender</label>
			    			<div class="col-sm-10">
								<label class="radio-inline">
					  				<input type="radio" name="gender" id="gender1_add_input" value="M" checked="checked"> 男
								</label>
								<label class="radio-inline">
					  				<input type="radio" name="gender" id="gender2_add_input" value="F"> 女
								</label>
			    			</div>
			  			</div>
			  			<div class="form-group">
			    			<label class="col-sm-2 control-label">deptName</label>
						    <div class="col-sm-4">
								<select class="form-control" name="dId"></select>
						    </div>
			  			</div>
					</form>
	      		</div>
		      	<div class="modal-footer">
		        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
		        	<button type="button" class="btn btn-primary" id="emp_save_btn">Save</button>
		      	</div>
	    	</div>
	  	</div>
	</div>
	
	<div class="modal fade" id="empUpdateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
	        	<div class="modal-header">
	            	<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
	                <h4 class="modal-title" id="myModalLabel2">employee update</h4>
	      		</div>
	      		<div class="modal-body">
	        		<form class="form-horizontal">
			  			<div class="form-group">
			    			<label class="col-sm-2 control-label">empName</label>
			    			<div class="col-sm-10">
			      				<p class="form-control-static" id="empName_update_static"></p>
			    			</div>
			  			</div>
			  			<div class="form-group">
			    			<label class="col-sm-2 control-label">email</label>
			    			<div class="col-sm-10">
			      				<input type="text" name="email" class="form-control" id="email_update_input" placeholder="例如'dai_biao@163.com'">
			    				<span class="help-block"></span>
			    			</div>
			  			</div>
			  			<div class="form-group">
			    			<label class="col-sm-2 control-label">gender</label>
			    			<div class="col-sm-10">
								<label class="radio-inline">
					  				<input type="radio" name="gender" id="gender1_update_input" value="M" checked="checked"> 男
								</label>
								<label class="radio-inline">
					  				<input type="radio" name="gender" id="gender2_update_input" value="F"> 女
								</label>
			    			</div>
			  			</div>
			  			<div class="form-group">
			    			<label class="col-sm-2 control-label">deptName</label>
						    <div class="col-sm-4">
								<select class="form-control" name="dId"></select>
						    </div>
			  			</div>
					</form>
	      		</div>
		      	<div class="modal-footer">
		        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
		        	<button type="button" class="btn btn-primary" id="emp_update_btn">Update</button>
		      	</div>
	    	</div>
	  	</div>
	</div>
	
	<div id="container" class="container">
		<div class="row">
			<div class="col-md-12">
				<h1>
					<span class="label label-default">SSM_SimpleProject</span>
				</h1>
			</div>
		</div>
		<div class="row">
			<div class="col-md-4 col-md-offset-8">
				<button id="emp_add_modal_btn" class="btn btn-primary btn-sm">
					<span class="glyphicon glyphicon-plus" aria-hidden="true"></span>&nbsp;&nbsp;add
				</button>
				<button id="emp_del_all_btn" class="btn btn-danger btn-sm">
					<span class="glyphicon glyphicon-minus" aria-hidden="true"></span>&nbsp;&nbsp;delete
				</button>
			</div>
		</div>
		<div class="row">
			<div class="col-md-12">
				<table id="emps_table" class="table table-hover">
					<thead>
						<tr>
							<th><input type="checkbox" id="checkAll"></input></th>
							<th>#</th>
							<th>empName</th>
							<th>gender</th>
							<th>email</th>
							<th>deptName</th>
							<th>operation</th>
						</tr>
					</thead>
					<tbody>

					</tbody>
				</table>
			</div>
		</div>
		<div class="row">
			<div class="col-md-12">
				<div id="page_info_area" class="col-md-6">当前页， 总页， 总共条记录</div>
				<div id="page_nav_area" class="col-md-6"></div>
			</div>
		</div>
	</div>
</body>
</html>