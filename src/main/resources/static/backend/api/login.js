function loginApi(data) {
  return $axios({
    'url': '/student/login',
    'method': 'post',
    data
  })
}

function logoutApi(){
  return $axios({
    'url': '/student/logout',
    'method': 'post',
  })
}
