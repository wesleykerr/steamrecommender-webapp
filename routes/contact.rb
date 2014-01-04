
post '/contact', :provides => :json  do
  readParams = JSON.parse(request.body.read)
  require 'net/smtp'
  from = readParams['email'] 
  to = 'steamrecommender@gmail.com'
  config = YAML::load_file( "#{File.expand_path('.')}/../config/steamrecommender.yml" )

  msg = <<EOF
From: #{readParams['name']} <#{readParams['email']}>
To: Steam Recommender <steamrecommender@gmail.com>
MIME-Version: 1.0
Content-type: text/plain
Subject: [steamrecommender.com] #{readParams['name']} has contacted you

#{readParams['name']} <#{readParams['email']}>
---

#{readParams['message']}
EOF

  smtp = Net::SMTP.new 'smtp.gmail.com', 587
  smtp.enable_starttls
  smtp.start('steamrecommender.com', config['mail_user'], config['mail_password'], :login) do
    smtp.send_message(msg, from, to)
  end
end


