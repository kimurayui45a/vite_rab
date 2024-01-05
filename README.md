

### 【行ったこと】
### ＜railsアプリ作成コマンド＞
まず、rails newコマンドは下記のようにしました。
docker-compose run web rails new . --force --database=postgresql --css=bootstrap --skip-javascript --skip-test

--css=bootstrap ：「-c bootstrap」の-cコマンドはrails7では使用できないとらんてくんやGPTから言われましたが本当ですか？今まで「-c bootstrap」で通じていました…

--skip-javascript ：rails7はデフォルトでimportmapを導入してしまうためjsのデフォルト設定を拒否する設定にしました。しかし、「turbo-rails
」は使用したいため後々「hotwire-rails」を入れる必要が出てきてしまいました。
どうしたらベストなのでしょうか？そもそもviteを使用する場合「hotwire-rails」が不要でしょうか？


### ＜vite_railsのインストール＞
gem経由でvite_railsをインストールすることにしました。
Gemfuleに「gem 'vite_rails’」を記述し、下記を実行しました。

bundle install

bundle exec vite install

生成されたファイル/ディレクトリ
「vite.config.js」
「app/frontend」

※発生したエラー
上記のみでは<%= vite_client_tag %>が読みこめずエラーになりました。
「bin/rails vite:install」を実行したらエラーはなおりましたが、正式なvite_railsのインストール手順が知りたいです。
「$ bundle exec vite install」で必要なファイルが作成されたため、正常にインストールできたと思ったのですがなぜでしょうか…
<%= vite_client_tag %> ：Viteの開発サーバーを使用している際にホットモジュールリロード（HMR）を有効にするためのもので、開発環境でのみ必要であり、本番環境では不要らしいです。


### ＜Vue.jsのインストール＞
yarn add vue

・vue用プラグイン「yarn add @vitejs/plugin-vue」をインストール
yarn add @vitejs/plugin-vue


### ＜vite.config.jsを修正＞
「vite.config.js」の内容
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    vue(),
    RubyPlugin()
  ],
})

import RubyPlugin from 'vite-plugin-ruby' ：ViteとRailsを統合するためのプラグイン。こちらは「vite.config.js」生成時に自動で記述されていました。


### ＜Vueコンポーネントの作成＞
「app/frontend」の中にVue用のディレクトリ「app/frontend/src」を作成します。


### ＜Procfile.dev の編集＞
「Procfile.dev」の中を下記にしました。
js: yarn vite
css: yarn watch:css

実行コマンドは「$ bin/dev」です。これであっていますか？
一応サーバーは起動し、cssもVueも読み込まれているらしいことは確認しました。

しかし、GPTはしきりに「css: yarn watch:css」は不要であり、viteは自動でcssを読み込むため「js: yarn vite」のみでcssも読み込めるはずであると言ってきます。

ですが、「js: yarn vite」のみでは「app/frontend」内のVueファイルに記述したcssしか読み込まれておらず、「app/assets/stylesheets」内のBootstrapなどのcssは読まれていませんでした。

viteとrailsでcssを別々で管理している状況がよくないような気がします。
もしどちらか片方にするならセットアップ時のコマンド「--css=bootstrap」を変更する必要が出てくるように思います。
bootstrapのインストールは手動だとなかなか大変だったように思いますので、できるだけセットアップ時に導入したいのですがどうなのでしょうか…

今の状況(viteとrailsでcssを別々で管理している)で問題ないでしょうか？


### ＜app/views/layouts/application.html.erbの設定＞
「app/views/layouts/application.html.erb」には下記2つを記述しております。
<%= vite_client_tag %>
 <%= vite_javascript_tag 'application' %>

vite用のcssの読み込みヘルパーで <%= vite_stylesheet_tag 'application' %> というものがあるようですが、
cssはrailsに管理させているため <%= stylesheet_link_tag "application" %> としています。

<%= vite_stylesheet_tag 'application' %>も記述した方が良いのでしょうか？


### ＜hotwire-railsのインストール＞
gem 'hotwire-rails'
bundle install
bin/rails hotwire:install

上記にて「app/javascript」が作成されました。

stimulusとturboを「app/frontend/entrypoints/application.js」に読み込ませる必要があるようですが、ここがよくわかりません。
現在発生しているエラーへの影響を増やしたくなかったため、一旦stimulusとturboを読み込ませる記述は削除しました。

自分としたは読み込みコードは下記ではないかなと思っています。

// Stimulusコントローラーの読み込み
import { Application } from "@hotwired/stimulus"
const application = Application.start()

application.debug = false
window.Stimulus   = application

export { application }

// Turboのインポート
import '@hotwired/turbo-rails';


GPTは下記のようにするように入っていましたが…

// Stimulusの初期化
import { Application } from '@hotwired/stimulus';
const application = Application.start();

// Stimulusコントローラーの読み込み
// Viteの場合、動的インポートを使用します
const controllers = import.meta.globEager('../controllers/**/*.js');
for (const path in controllers) {
  const controller = controllers[path].default;
  if (controller) {
    const controllerName = path.split('/').pop().replace(/_controller\.js$/, '').replace(/_/g, '-');
    application.register(controllerName, controller);
  }
}

// Turboのインポート
import '@hotwired/turbo-rails';


### ＜Vueの動作テスト用のコード＞
「app/frontend/entrypoints/application.js」に下記を記述してVueを読み込ませます。
// Vueの初期化
import { createApp } from 'vue';
import ExampleComponent from '../src/components/ExampleComponent.vue';

document.addEventListener('DOMContentLoaded', () => {
  const vueEl = document.getElementById('vue-app');
  if (vueEl) {
    createApp(ExampleComponent).mount(vueEl);
  }
});


「app/frontend/src/components/ExampleComponent.vue」に簡単なボタンクリックをカウントするコードを記述し、id要素で「app/views/vues/index.html.erb」を通じて表示させています。

