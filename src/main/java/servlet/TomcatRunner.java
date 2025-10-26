package servlet;

import java.io.File;

import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.connector.Connector;

/**
 * 組み込みTomcat起動クラス RUN環境では /webapp を優先。 /webapp/webapp がある場合にも対応。
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

        Connector connector = new Connector();
        connector.setScheme("http");
        connector.setPort(port);
        connector.setProperty("address", "0.0.0.0");
        tomcat.getService().addConnector(connector);
        tomcat.setConnector(connector);

        // 優先パスの順序
        String webappDirLocation = null;

        // 1) /webapp/index.jsp があるか
        File webappRoot = new File("/webapp");
        File webappIndex = new File("/webapp/index.jsp");
        if (webappIndex.exists() && webappIndex.isFile()) {
            webappDirLocation = webappRoot.getAbsolutePath();
        } else {
            // 2) /webapp/webapp/index.jsp があるか（Docker のコピーで一段深くなっている場合）
            File nested = new File("/webapp/webapp");
            File nestedIndex = new File("/webapp/webapp/index.jsp");
            if (nestedIndex.exists() && nestedIndex.isFile()) {
                webappDirLocation = nested.getAbsolutePath();
            } else {
                // 3) 開発環境の src/main/webapp を使用
                String dev = "src/main/webapp/";
                if (new File(dev).exists()) {
                    webappDirLocation = new File(dev).getAbsolutePath();
                } else {
                    // 最終フォールバック: カレントディレクトリ
                    webappDirLocation = new File(".").getAbsolutePath();
                }
            }
        }

        System.out.println("Using webapp directory: " + webappDirLocation);
        tomcat.addWebapp("", webappDirLocation);

        System.out.println("Starting Tomcat on port: " + port);
        tomcat.start();
        tomcat.getServer().await();
    }
}
