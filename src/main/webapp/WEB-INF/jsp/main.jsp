<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User,model.Mutter,java.util.List" %>
<%!
/* HTMLエスケープ（必須） */
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

/* 表示用にゼロ幅スペースを挿入して折り返しを容易にする（元データは変更しない） */
public static String insertZwsp(String s, int interval) {
    if (s == null || interval <= 0) return s == null ? "" : s;
    StringBuilder sb = new StringBuilder(s.length() + s.length()/interval + 4);
    int count = 0;
    for (int i = 0; i < s.length(); i++) {
        sb.append(s.charAt(i));
        if (++count >= interval) {
            sb.append('\u200B'); // ゼロ幅スペース
            count = 0;
        }
    }
    return sb.toString();
}
%>
<%
User loginUser = (User) session.getAttribute("loginUser");
List<Mutter> mutterList = (List<Mutter>) application.getAttribute("mutterList");
String errorMsg = (String) request.getAttribute("errorMsg");
if (loginUser == null) {
    response.sendRedirect("Login");
    return;
}
%>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>簡易版コメント投稿</title>
  <link rel="stylesheet" href="css/style.css">
  <meta name="viewport" content="width=device-width,initial-scale=1">
</head>
<body>
  <h1>簡易版コメント投稿</h1>

  <p class="user-info">
    <%= escapeHtml(loginUser.getName()) %>さん、ログイン中
    <a href="Logout">ログアウト</a>
  </p>

  <p><a href="Main">更新</a></p>

  <form action="Main" method="post" autocomplete="off" accept-charset="UTF-8">
    <!-- 入力上限をクライアントで制限（サーバー側でも必ず検証すること） -->
    <input type="text" name="text" maxlength="2000" placeholder="つぶやきを入力（最大2000文字）" required>
    <input type="submit" value="つぶやく">
  </form>

  <% if (errorMsg != null) { %>
    <p class="error-msg"><%= escapeHtml(errorMsg) %></p>
  <% } %>

  <div class="mutter-list">
    <% if (mutterList != null) {
         for (Mutter mutter : mutterList) {
             String userName = escapeHtml(mutter.getUserName());
             String rawText = mutter.getText();
             String safeText = escapeHtml(rawText);
             /* 表示用に 30 文字ごとにゼロ幅スペースを入れる（調整可） */
             String displayText = insertZwsp(safeText, 30);
    %>
      <p><strong><%= userName %></strong>：<span class="mutter-text"><%= displayText %></span></p>
    <%   }
       } %>
  </div>

  <!-- 表示補助スクリプト（コピー等でZWSPを除去したい場合の例） -->
  <script>
    (function(){
      /* コピー時にゼロ幅スペースを取り除いてクリップボードへ */
      document.addEventListener('copy', function(e){
        var sel = window.getSelection().toString();
        if (!sel) return;
        var cleaned = sel.replace(/\u200B/g, '');
        e.clipboardData.setData('text/plain', cleaned);
        e.preventDefault();
      });
    })();
  </script>
</body>
</html>
