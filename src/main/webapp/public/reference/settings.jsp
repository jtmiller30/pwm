<%@ page import="password.pwm.config.PwmSettingCategory" %>
<%@ page import="password.pwm.config.PwmSettingSyntax" %>
<%@ page import="password.pwm.config.PwmSettingTemplate" %>
<%@ page import="password.pwm.error.PwmException" %>
<%@ page import="password.pwm.http.JspUtility" %>
<%@ page import="password.pwm.util.StringUtil" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%--
  ~ Password Management Servlets (PWM)
  ~ http://code.google.com/p/pwm/
  ~
  ~ Copyright (c) 2006-2009 Novell, Inc.
  ~ Copyright (c) 2009-2015 The PWM Project
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or
  ~ (at your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  ~
  --%>

<!DOCTYPE html>
<% JspUtility.setFlag(pageContext, PwmRequest.Flag.HIDE_HEADER_WARNINGS); %>
<% JspUtility.setFlag(pageContext, PwmRequest.Flag.HIDE_THEME); %>
<% JspUtility.setFlag(pageContext, PwmRequest.Flag.NO_REQ_COUNTER); %>
<% JspUtility.setFlag(pageContext, PwmRequest.Flag.NO_IDLE_TIMEOUT); %>
<% JspUtility.setFlag(pageContext, PwmRequest.Flag.HIDE_HEADER_BUTTONS); %>
<% JspUtility.setFlag(pageContext, PwmRequest.Flag.HIDE_FOOTER_TEXT); %>
<%@ page language="java" session="true" isThreadSafe="true" contentType="text/html" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<% final Locale userLocale = JspUtility.locale(request); %>
<%
    final PwmRequest pwmRequest = JspUtility.getPwmRequest(pageContext);
    boolean advancedMode = false;
    List<PwmSettingCategory> sortedCategories = new ArrayList();
    try {
        advancedMode = pwmRequest != null && pwmRequest.hasParameter("advanced");
        sortedCategories.addAll(PwmSettingCategory.sortedValues(JspUtility.locale(request)));
        for (Iterator<PwmSettingCategory> iterator = sortedCategories.iterator(); iterator.hasNext(); ) {
            PwmSettingCategory category = iterator.next();
            if (category.isHidden() || (category.getSettings().isEmpty() && category.getDescription(userLocale).isEmpty())) {
                iterator.remove();
            }
        }

    } catch (PwmException e) {
        JspUtility.logError(pageContext, "error during page setup: " + e.getMessage());
    }
%>
<html dir="<pwm:LocaleOrientation/>">
<%@ include file="/WEB-INF/jsp/fragment/header.jsp" %>
<body class="nihilo">
<div id="wrapper">
    <jsp:include page="/WEB-INF/jsp/fragment/header-body.jsp">
        <jsp:param name="pwm.PageName" value="Setting Reference"/>
    </jsp:include>
    <div id="centerbody" style="width: 800px">
        <%@ include file="reference-nav.jsp"%>
        <ol>
            <% for (final PwmSettingCategory category : sortedCategories) { %>
            <li><a href="#settings_category_<%=category.toString()%>"><%=category.toMenuLocationDebug(null,userLocale)%></a></li>
            <% } %>
        </ol>
        <br/>
        <% for (final PwmSettingCategory category : sortedCategories) { %>
        <h2><a id="settings_category_<%=category.toString()%>"><%=category.getLabel(userLocale)%></a></h2>
        <p>
            <%=category.getDescription(userLocale)%>
        </p>
        <% for (final PwmSetting setting : category.getSettings()) { %>
        <% if (!setting.isHidden()) { %>
        <a id="setting_key_<%=setting.getKey()%>"  style="font-weight: inherit; text-decoration: none">
            <table>
                <tr>
                    <td class="key" style="width: 100px">

                        <div style="text-align: left">
                            <a href="#setting_key_<%=setting.getKey()%>" style="text-decoration: inherit">
                                <span class="btn-icon fa fa-link"></span>
                            </a>
                        </div>
                        Label
                    </td>
                    <td>
                        <%=setting.getLabel(userLocale)%>
                    </td>
                </tr>
                <tr>
                    <td class="key" style="width: 100px">
                        Key
                    </td>
                    <td>
                        <%=setting.getKey()%>
                    </td>
                </tr>
                <tr>
                    <td class="key" style="width: 100px">
                        Navigation
                    </td>
                    <td>
                        <%=setting.toMenuLocationDebug(null,userLocale)%>
                    </td>
                </tr>
                <tr>
                    <td class="key" style="width: 100px">
                        Syntax
                    </td>
                    <td>
                        <%=setting.getSyntax()%>
                    </td>
                </tr>
                <tr>
                    <td class="key" style="width: 100px">
                        Level
                    </td>
                    <td>
                        <%=setting.getLevel()%>
                        <% if (setting.getLevel() == 0) { %>
                        (Normal)
                        <% } else if (setting.getLevel() == 1) { %>
                        (Advanced)
                        <% } %>
                    </td>
                </tr>
                <tr>
                    <td class="key" style="width: 100px">
                        Required
                    </td>
                    <td>
                        <%=setting.isRequired()%>
                    </td>
                </tr>
                <tr>
                    <td class="key" style="width: 100px">
                        Confidential
                    </td>
                    <td>
                        <%=setting.isConfidential()%>
                    </td>
                </tr>
                <% if (setting.getSyntax() == PwmSettingSyntax.OPTIONLIST || setting.getSyntax() == PwmSettingSyntax.SELECT) { %>
                <tr>
                    <td class="key" style="width: 100px">
                        Options
                    </td>
                    <td>
                        <table>
                            <thead>
                            <tr><td><b>Stored Value</b></td><td><b>Display</b></td></tr>
                            </thead>
                            <tbody>
                            <% for (final String key : setting.getOptions().keySet()) { %>
                            <tr>
                                <td>
                                    <%=key%>
                                </td>
                                <td>
                                    <%=setting.getOptions().get(key)%>
                                </td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </td>
                </tr>
                <% } %>
                <% final Map<PwmSettingTemplate,String> defaultValues = setting.getDefaultValueDebugStrings(userLocale); %>
                <tr>
                    <td class="key" style="width: 100px">
                        Default
                    </td>
                    <td style="max-width: 690px; overflow-x: auto">
                        <% if (defaultValues.size() > 1) { %>
                        <table>
                            <thead>
                            <tr><td><b>Template</b></td><td><b>Value</b></td></tr>
                            </thead>
                            <tbody>
                            <%
                                for (final PwmSettingTemplate template : defaultValues.keySet()) {
                                    final String defaultValue = defaultValues.get(template);
                            %>
                            <tr><td><%=template.getLabel(userLocale)%></td><td>
                                <%=defaultValue == null ? "" : StringUtil.escapeHtml(defaultValue)%>
                            </td></tr>
                            <% } %>
                            </tbody>
                        </table>
                        <%
                        } else if (defaultValues.size() == 1) {
                            final String defaultValue = defaultValues.values().iterator().next();
                        %>
                        <pre><%=defaultValue == null ? "" : StringUtil.escapeHtml(defaultValue)%></pre>
                        <% } %>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <%=setting.getDescription(userLocale)%>
                    </td>
                </tr>
                <% } %>
            </table>
        </a>
        <br/>
        <% } %>
        <% } %>
        <% if (advancedMode) { %>
        <h2><a id="settingStatistics">Setting Statistics</a></h2>
        <% Map<PwmSetting.SettingStat,Object> settingStats = PwmSetting.getStats(); %>
        <table>
            <tr>
                <td>
                    Total Settings
                </td>
                <td>
                    <%= settingStats.get(PwmSetting.SettingStat.Total) %>
                </td>
            </tr>
            <tr>
                <td>
                    Settings that are part of a Profile
                </td>
                <td>
                    <%= settingStats.get(PwmSetting.SettingStat.hasProfile) %>
                </td>
            </tr>
            <% Map<PwmSettingSyntax,Integer> syntaxCounts = (Map<PwmSettingSyntax,Integer>)settingStats.get(PwmSetting.SettingStat.syntaxCounts); %>
            <% for (final PwmSettingSyntax loopSyntax : syntaxCounts.keySet()) { %>
            <tr>
                <td>
                    Settings with syntax type <%= loopSyntax.toString() %>
                </td>
                <td>
                    <%= syntaxCounts.get(loopSyntax) %>
                </td>
            </tr>
            <% } %>
        </table>

        <h2><a id="appProperties">Application Properties</a></h2>
        <table>
            <tr>
                <td class="key" style="text-align: left">
                    Key
                </td>
                <td class="key" style="text-align: left">
                    Default Value
                </td>
            </tr>
            <% for (final AppProperty appProperty : AppProperty.values()) { %>
            <tr>
                <td style="width: auto; white-space: nowrap; text-align: left">
                    <%=appProperty.getKey()%>
                </td>
                <td>
                    <%=appProperty.getDefaultValue()%>
                </td>
            </tr>
            <% } %>
        </table>
        <% } %>
        <div class="push"></div>
    </div>
</div>
<%@ include file="/WEB-INF/jsp/fragment/footer.jsp" %>
</body>
</html>
