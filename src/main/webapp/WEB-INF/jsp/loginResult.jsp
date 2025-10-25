<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
  // セッションスコープからユーザー情報を取得
  User loginUser = (User) session.getAttribute("loginUser");
  // HTMLエスケープ関数（ページ内に追加）
%>
<%! 
public static String escapeHtml(String s) {
    if (s == null) return "";
    StringBuilder sb = new StringBuilder(s.length());
    for (char c : s.toCharArray()) {
        switch (c) {
            case '<': sb.append("&lt;"); break;
            case '>': sb.append("&gt;"); break;
            case '&': sb.append("&amp;"); break;
            case '"': sb.append("&quot;"); break;
            case '\'': sb.append("&#x27;"); break;
            case '/': sb.append("&#x2F;"); break;
            default: sb.append(c);
        }
    }
    return sb.toString();
}
%>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>簡易版コメント投稿 - ログイン結果</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
  <h1>簡易版コメント投稿</h1>

  <% if (loginUser != null) { %>
    <p>ログインに成功しました</p>
    <p>ようこそ <strong><%= escapeHtml(loginUser.getName()) %></strong> さん</p>
    <p><a href="Main">コメント投稿・閲覧へ</a></p>
  <% } else { %>
    <p>ログインに失敗しました</p>
    <p><a href="index.jsp">トップへ</a></p>
  <% } %>
</body>
</html>
```