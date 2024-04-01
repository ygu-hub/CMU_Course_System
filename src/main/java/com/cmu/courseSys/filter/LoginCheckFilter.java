package com.cmu.courseSys.filter;

import com.alibaba.fastjson.JSON;
import com.cmu.courseSys.common.R;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.AntPathMatcher;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
@Slf4j
@WebFilter(filterName = "loginCheckFilter", urlPatterns = "/*")
// The WebFilter to filter the appropriate request to our login-required pages
public class LoginCheckFilter implements Filter {
    // 路径匹配器，支持通配符
    public static final AntPathMatcher PATH_MATCHER = new AntPathMatcher();
    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        // get the current request uri and check if the uri is allowed in default
        String requestURI = request.getRequestURI();
        log.info("Intercept Request: {}", requestURI);

        String[] allowURIs = new String[]{
                "/student/login",
                "/student/logout",
                "/backend/**",
                "front/**"
        };
        // if the request uri is allowed by default, let the request directly pass the filter
        if(checkURI(allowURIs, requestURI)){
            log.info("allowed uri {}", requestURI);
            filterChain.doFilter(request,response);
            return;
        }

        // if no, check if the user is logged in already
        if(request.getSession().getAttribute("student") != null){
            log.info("uri request valid, user {} logged in already. ", request.getSession().getAttribute("student"));
            filterChain.doFilter(request,response);
            return;
        }

        // reject request if visiting log-in required page, but the user hasn't logged in yet.
        // 通过输出流方式，向客户端页面发送相应数据，并在 request.js里被拦截后，跳转到 login 界面
        log.error("uri request invalid {}, back to login page", requestURI);
        response.getWriter().write(JSON.toJSONString(R.error("NOTLOGIN")));

    }

    private boolean checkURI(String[] uris, String targetURI){
        for (String s : uris) {
            if(PATH_MATCHER.match(s, targetURI)){
               return true;
            }
        }
        return false;
    }
}
