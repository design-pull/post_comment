<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  // セッション破棄（ログアウト処理をここで行う場合）
  if (session != null) {
      session.invalidate();
  }
%>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>簡易版コメント投稿 - ログアウト</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
  <h1>簡易版コメント投稿</h1>
  <p>ログアウトしました</p>
  <p><a href="index.jsp">トップへ</a></p>
</body>
</html>
