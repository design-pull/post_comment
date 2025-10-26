package servlet;

import java.io.File;
import java.net.URL;

import org.apache.catalina.Context;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.connector.Connector;
import org.apache.catalina.loader.WebappLoader;

/**
 * 組み込みTomcat起動クラス /webapp (または /webapp/webapp / src/main/webapp) をルートにし、 /app.jar を webapp
 * のクラスローダに追加して Servlet クラスを利用可能にする
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

        // webapp 配置候補（優先順）
        String webappDirLocation = null;
        File webappRoot = new File("/webapp");
        if (new File("/webapp/index.jsp").exists()) {
            webappDirLocation = webappRoot.getAbsolutePath();
        } else if (new File("/webapp/webapp/index.jsp").exists()) {
            webappDirLocation = new File("/webapp/webapp").getAbsolutePath();
        } else if (new File("src/main/webapp").exists()) {
            webappDirLocation = new File("src/main/webapp").getAbsolutePath();
        } else {
            webappDirLocation = new File(".").getAbsolutePath();
        }

        System.out.println("Using webapp directory: " + webappDirLocation);

        // コンテキストを生成
        Context ctx = tomcat.addWebapp("", webappDirLocation);

        // /app.jar をコンテキストのクラスローダに追加して Servlet クラスを読み込めるようにする
        File appJar = new File("/app.jar");
        if (appJar.exists()) {
            URL jarUrl = appJar.toURI().toURL();
            WebappLoader loader = new WebappLoader(Thread.currentThread().getContextClassLoader());
            // addRepository が文字列（URL）を受け取る実装なので toString() を使う
            loader.addRepository(jarUrl.toString());
            ctx.setLoader(loader);
            System.out.println("Added /app.jar to webapp classloader: " + jarUrl);
        } else {
            System.out.println("/app.jar not found; relying on classes in webapp");
        }

        System.out.println("Starting Tomcat on port: " + port);
        tomcat.start();
        tomcat.getServer().await();
    }
}
