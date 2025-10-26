package servlet;

import java.io.File;

import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.connector.Connector;

/**
 * 組み込みTomcat起動クラス RUN環境では /webapp を優先、開発時は src/main/webapp を使用する
 */
public class TomcatRunner {

    public static void main(String[] args) throws Exception {
        String portEnv = System.getenv("PORT");
        int port;
        try {
            port = (portEnv != null && !portEnv.isBlank()) ? Integer.parseInt(portEnv) : 8080;
        } catch (NumberFormatException e) {
            port = 8080;
        }

        Tomcat tomcat = new Tomcat();

        // 明示的に 0.0.0.0 にバインドするコネクタを作成
        Connector connector = new Connector();
        connector.setScheme("http");
        connector.setPort(port);
        connector.setProperty("address", "0.0.0.0");
        tomcat.getService().addConnector(connector);
        tomcat.setConnector(connector);

        // コンテナ実行時の配置先を優先して使う
        String webappDirLocation;
        File webappOnContainer = new File("/webapp");
        if (webappOnContainer.exists() && webappOnContainer.isDirectory()) {
            webappDirLocation = webappOnContainer.getAbsolutePath();
        } else {
            // 開発環境用のパス
            webappDirLocation = "src/main/webapp/";
            if (!new File(webappDirLocation).exists()) {
                // fallback: カレントディレクトリ
                webappDirLocation = new File(".").getAbsolutePath();
            }
        }

        System.out.println("Using webapp directory: " + webappDirLocation);
        tomcat.addWebapp("", webappDirLocation);

        System.out.println("Starting Tomcat on port: " + port);
        tomcat.start();
        tomcat.getServer().await();
    }
}
