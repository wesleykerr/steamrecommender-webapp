
get '/contact' do
  haml :contact
end

post '/contact' do
  puts params[:email]
  require 'net/smtp'
  from = params[:email] 
  to = 'steamrecommender@gmail.com'
  msg = <<EOF
From: #{params[:name]} <#{params[:email]}>
To: Steam Recommender <steamrecommender@gmail.com>
MIME-Version: 1.0
Content-type: text/plain
Subject: [steamrecommender.com] #{params[:name]} has contacted you

#{params[:name]} <#{params[:email]}>
---

#{params[:message]}
EOF

  smtp = Net::SMTP.new 'smtp.gmail.com', 587
  smtp.enable_starttls
  smtp.start('steamrecommender.com', @@config['mail_user'], @@config['mail_password'], :login) do
    smtp.send_message(msg, from, to)
  end
  redirect '/success'
end

get '/success' do
  haml :success
end

