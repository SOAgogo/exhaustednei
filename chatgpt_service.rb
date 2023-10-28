# http://www.rubydoc.info/github/google/google-api-ruby-client/Google/Apis/CalendarV3
require 'googleauth'
require 'google/apis/calendar_v3'
require 'google-api-client'

token_path = './google_api.json' # ユーザーのAPIトークンの保存先
scope = Google::Apis::CalendarV3::AUTH_CALENDAR_EVENTS # Google Cloudコンソールで設定したスコープ
callback_path = '/google_calendar/callback' # Google Cloudコンソールで設定したリダイレクトURIのパス部分

oauth_client = Google::Auth::UserAuthorizer.new(
 Google::Auth::ClientId.from_file(token_path),
 scope,
 Google::Auth::Stores::FileTokenStore.new(file: token_path),
 callback_path
)

base_url = 'http://localhost:3000' # Google Cloudコンソールで設定したリダイレクトURIのベース部分
@authorization_url = oauth_client.get_authorization_url(base_url: base_url)