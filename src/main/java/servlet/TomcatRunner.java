package servlet;

import java.io.File;

import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.connector.Connector;

/**
 * 組み込みTomcatを起動するためのメインクラス Renderの環境変数PORTを使用して、Webサービスとして公開します。
 */
public class TomcatRunner {

    public static void main(String[] args) throws Exception {
        // Renderの環境変数PORTを取得（設定されていない場合は8080を使用）
        String portEnv = System.getenv("PORT");
        int port;
        try {
            port = (portEnv != null && !portEnv.isBlank()) ? Integer.parseInt(portEnv) : 8080;
        } catch (NumberFormatException e) {
            port = 8080;
        }

        // Tomcatインスタンス作成
        Tomcat tomcat = new Tomcat();

        // コネクタを作成して0.0.0.0にバインド（Renderが外部からポートを検出できるようにする）
        Connector connector = new Connector();
        connector.setScheme("http");
        connector.setPort(port);
        connector.setProperty("address", "0.0.0.0");

        // サービスにコネクタを追加してデフォルトコネクタに設定
        tomcat.getService().addConnector(connector);
        tomcat.setConnector(connector);

        // 開発環境とWebアプリのルート（JSPや静的ファイルがある場所）を指定
        String webappDirLocation = "src/main/webapp/";
        if (!new File(webappDirLocation).exists()) {
            webappDirLocation = new File(".").getAbsolutePath();
        }

        // Webアプリケーションをルートコンテキストでデプロイ
        tomcat.addWebapp("", webappDirLocation);

        System.out.println("Starting Tomcat on port: " + port);

        tomcat.start();
        tomcat.getServer().await();
    }
}
