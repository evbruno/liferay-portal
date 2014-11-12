<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/html/portlet/users_admin/init.jsp" %>

<%
User selUser = (User)request.getAttribute("user.selUser");
List<UserGroup> userGroups = (List<UserGroup>)request.getAttribute("user.userGroups");

currentURLObj.setParameter("historyKey", renderResponse.getNamespace() + "userGroups");
%>

<liferay-ui:error-marker key="errorSection" value="user-groups" />

<liferay-ui:membership-policy-error />

<liferay-util:buffer var="removeUserGroupIcon">
	<liferay-ui:icon
		iconCssClass="icon-remove"
		label="<%= true %>"
		message="remove"
	/>
</liferay-util:buffer>

<aui:input name="addUserGroupIds" type="hidden" />
<aui:input name="deleteUserGroupIds" type="hidden" />

<h3><liferay-ui:message key="user-groups" /></h3>

<liferay-ui:search-container
	curParam="userGroupsCur"
	headerNames="name,null"
	iteratorURL="<%= currentURLObj %>"
	total="<%= userGroups.size() %>"
>
	<liferay-ui:search-container-results
		results="<%= userGroups.subList(searchContainer.getStart(), searchContainer.getResultEnd()) %>"
	/>

	<liferay-ui:search-container-row
		className="com.liferay.portal.model.UserGroup"
		escapedModel="<%= true %>"
		keyProperty="userGroupId"
		modelVar="userGroup"
	>
		<liferay-ui:search-container-column-text
			name="name"
			property="name"
		/>

		<c:if test="<%= !portletName.equals(PortletKeys.MY_ACCOUNT) && !UserGroupMembershipPolicyUtil.isMembershipRequired(selUser.getUserId(), userGroup.getUserGroupId()) %>">
			<liferay-ui:search-container-column-text>
				<a class="modify-link" data-rowId="<%= userGroup.getUserGroupId() %>" href="javascript:;"><%= removeUserGroupIcon %></a>
			</liferay-ui:search-container-column-text>
		</c:if>
	</liferay-ui:search-container-row>

	<liferay-ui:search-iterator />
</liferay-ui:search-container>

<c:if test="<%= !portletName.equals(PortletKeys.MY_ACCOUNT) %>">
	<liferay-ui:icon
		cssClass="modify-link"
		iconCssClass="icon-search"
		id="openUserGroupsLink"
		label="<%= true %>"
		linkCssClass="btn btn-default"
		message="select"
		url="javascript:;"
	/>

	<aui:script use="escape,liferay-search-container">
		var Util = Liferay.Util;

		var searchContainer = Liferay.SearchContainer.get('<portlet:namespace />userGroupsSearchContainer');

		var searchContainerContentBox = searchContainer.get('contentBox');

		var <portlet:namespace />addUserGroupIds = [];
		var <portlet:namespace />deleteUserGroupIds = [];

		searchContainerContentBox.delegate(
			'click',
			function(event) {
				var link = event.currentTarget;

				var rowId = link.attr('data-rowId');

				var tr = link.ancestor('tr');

				var selectUserGroup = Util.getWindow('<portlet:namespace />selectUserGroup');

				if (selectUserGroup) {
					var selectButton = selectUserGroup.iframe.node.get('contentWindow.document').one('.selector-button[data-usergroupid="' + rowId + '"]');

					Util.toggleDisabled(selectButton, false);
				}

				searchContainer.deleteRow(tr, rowId);

				for (var i = 0; i < <portlet:namespace />addUserGroupIds.length; i++) {
					if (<portlet:namespace />addUserGroupIds[i] == rowId) {
						<portlet:namespace />addUserGroupIds.splice(i, 1);

						break;
					}
				}

				<portlet:namespace />deleteUserGroupIds.push(rowId);

				document.<portlet:namespace />fm.<portlet:namespace />addUserGroupIds.value = <portlet:namespace />addUserGroupIds.join(',');
				document.<portlet:namespace />fm.<portlet:namespace />deleteUserGroupIds.value = <portlet:namespace />deleteUserGroupIds.join(',');
			},
			'.modify-link'
		);

		Liferay.on(
			'<portlet:namespace />enableRemovedUserGroups',
			function(event) {
				event.selectors.each(
					function(item, index, collection) {
						var modifyLink = searchContainerContentBox.one('.modify-link[data-rowid="' + item.attr('data-usergroupid') + '"]');

						if (!modifyLink) {
							Util.toggleDisabled(item, false);
						}
					}
				);
			}
		);

		A.one('#<portlet:namespace />openUserGroupsLink').on(
			'click',
			function(event) {
				Util.selectEntity(
					{
						dialog: {
							constrain: true,
							modal: true,
							width: 680
						},
						id: '<portlet:namespace />selectUserGroup',
						title: '<liferay-ui:message arguments="user-group" key="select-x" />',

						<portlet:renderURL var="selectUserGroupURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
							<portlet:param name="struts_action" value="/user_groups_admin/select_user_group" />
							<portlet:param name="p_u_i_d" value="<%= String.valueOf(selUser.getUserId()) %>" />
						</portlet:renderURL>

						uri: '<%= selectUserGroupURL.toString() %>'
					},
					function(event) {
						var A = AUI();

						var rowColumns = [];

						rowColumns.push(A.Escape.html(event.usergroupname));
						rowColumns.push('<a class="modify-link" data-rowId="' + event.usergroupid + '" href="javascript:;"><%= UnicodeFormatter.toString(removeUserGroupIcon) %></a>');

						searchContainer.addRow(rowColumns, event.usergroupid);
						searchContainer.updateDataStore();

						for (var i = 0; i < <portlet:namespace />deleteUserGroupIds.length; i++) {
							if (<portlet:namespace />deleteUserGroupIds[i] == event.usergroupid) {
								<portlet:namespace />deleteUserGroupIds.splice(i, 1);

								break;
							}
						}

						<portlet:namespace />addUserGroupIds.push(event.usergroupid);

						document.<portlet:namespace />fm.<portlet:namespace />addUserGroupIds.value = <portlet:namespace />addUserGroupIds.join(',');
						document.<portlet:namespace />fm.<portlet:namespace />deleteUserGroupIds.value = <portlet:namespace />deleteUserGroupIds.join(',');
					}
				);
			}
		);
	</aui:script>
</c:if>