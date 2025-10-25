package servlet;

import java.io.File;

import org.apache.catalina.startup.Tomcat;

/**
 * 組み込みTomcatを起動するためのメインクラス
 * Renderの環境変数PORTを使用して、Webサービスとして公開します。
 */
public class TomcatRunner {

    public static void main(String[] args) throws Exception {
        // Renderの環境変数PORTを取得（設定されていない場合は8080を使用）
        String port = System.getenv("PORT");
        if (port == null || port.isEmpty()) {
            port = "8080";
        }

        Tomcat tomcat = new Tomcat();
        tomcat.setPort(Integer.valueOf(port));
        
        // 開発環境とWebアプリのルート（JSPや静的ファイルがある場所）を指定
        // このパスはMaven WARビルドの標準出力ディレクトリです
        String webappDirLocation = "src/main/webapp/";
        if (!new File(webappDirLocation).exists()) {
             // ビルド後の実行可能JAR内では、WARファイルがルートコンテキストになる
             webappDirLocation = new File(".").getAbsolutePath();
        }

        // TomcatにWebアプリケーション（プロジェクト全体）をルートコンテキスト("/")でデプロイ
        // 第二引数の "/" が、アプリケーションをルートパスで起動することを意味します。
        tomcat.addWebapp("", webappDirLocation); 

        System.out.println("Starting Tomcat on port: " + port);
        
        tomcat.start();
        // サーバーが停止しないようにメインスレッドを待機させる
        tomcat.getServer().await();
    }
}
