#!/bin/bash

set -e

#incldue system wide var
. /etc/environment

echo "init dirctory in etcd for haproxy-confd"

etcdctl mkdir /haproxy/global
etcdctl mkdir /haproxy/defaults
etcdctl mkdir /haproxy/peers
etcdctl mkdir /haproxy/frontend-list
etcdctl mkdir /haproxy/backend-list
etcdctl mkdir /haproxy/frontend  
etcdctl mkdir /haproxy/backend 
etcdctl mkdir /haproxy/listen
etcdctl mkdir /haproxy/listen-list
etcdctl mkdir /haproxy/user-list
etcdctl mkdir /haproxy/userlist

echo "add some init data to avoid the confd error which casued by no data under the directory"

echo "init data for global section"
echo "...Process management and security"
#etcdctl set /haproxy/global/chroot                             "chroot /var/haproxy"
etcdctl set /haproxy/global/daemon                              "daemon"
#etcdctl set /haproxy/global/gid                                "gid 0"
#etcdctl set /haproxy/global/group                              "group haproxy"
#etcdctl set /haproxy/global/log                                "log 127.0.0.1 local1"
#etcdctl set /haproxy/global/log-send-hostname                  "log-send-hostname haproxy"
#etcdctl set /haproxy/global/log-tag                            "log-tag haproxy1"
#etcdctl set /haproxy/global/nbproc                             "nbproc 1"
#etcdctl set /haproxy/global/pidfile                            "pidfile /var/run/haproxy.pid"
#etcdctl set /haproxy/global/stats_socket                       "stats socket /etc/haproxy/haproxy.socket level admin"
#etcdctl set /haproxy/global/stats_timeout                      "stats timeout 30s"
#etcdctl set /haproxy/global/stats_maxconn                      "stats maxconn 10"
#etcdctl set /haproxy/global/uid                                "uid 0" 
#etcdctl set /haproxy/global/ulimit-n                           "ulimit-n 1024"
#etcdctl set /haproxy/global/unix-bind                          "unix-bind prfix /etc/haproxy mode http"
#etcdctl set /haproxy/global/user                               "user root"
#need to set the unique name in the cluster if using active-ative mode
#etcdctl set /haproxy/global/node                               "node haproxy1"
#etcdctl set /haproxy/global/description                        "description this is my haproxy"

echo "...Performance tuning"
etcdctl set /haproxy/global/maxconn                             "maxconn 1024"
#etcdctl set /haproxy/global/maxconnrate                        "maxconnrate 1024"
#etcdctl set /haproxy/global/maxpipes                           "maxpipes 256"
#etcdctl set /haproxy/global/noepoll                            "noepoll"
#BSD system only for nokqueue
#etcdctl set /haproxy/global/nokqueue                           "nokqueue"
#not to use it because select will be used
#etcdctl set /haproxy/global/nopoll                             "nopoll"
#etcdctl set /haproxy/global/nosepoll                           "nosepoll"
#etcdctl set /haproxy/global/nosplice                           "nosplice"
etcdctl set /haproxy/global/spread-checks                       "spread-checks 3"
#Not to change the default value of tune.bufsize (16384) and tune.chksize (16384)
#etcdctl set /haproxy/global/tune.bufsize                       "tune.bufsize 16384"
#etcdctl set /haproxy/global/tune.chksize                       "tune.chksize 16384"
#etcdctl set /haproxy/global/tune.http.maxhdr                   "tune.http.maxhdr 101"
#etcdctl set /haproxy/global/tune.maxaccept                     "tune.maxaccept 100"
#etcdctl set /haproxy/global/tune.maxpollevents                 "tune.maxpollevents 200"
etcdctl set /haproxy/global/tune.maxrewrite                     "tune.maxrewrite 1024"
#etcdctl set /haproxy/global/tune.pipesize                      "tune.pipesize "
#let knernel decider the rcvbuf(0) or 4096 to save kernel memory but increase CPU usage
#etcdctl set /haproxy/global/tune.rcvbuf.client                 "tune.rcvbuf.client 0"
#etcdctl set /haproxy/global/tune.rcvbuf.server                 "tune.rcvbuf.server 0"
#let knernel decider the sndbuf(0)  or 4096 to save kernel memory but increase CPU usage
#etcdctl set /haproxy/global/tune.sndbuf.client                 "tune.sndbuf.client "
#etcdctl set /haproxy/global/tune.sndbuf.server                 "tune.sndbuf.server "

echo "...Debuggin"
#etcdctl set /haproxy/global/debug                              "debug"
#etcdctl set /haproxy/global/quiet                              "quiet"

echo "...Userlists"

#It is possible to control access to frontend/backend/listen sections or to http stats by
#allowing only authenticated and authorized users.

etcdctl set /haproxy/user-list/default-ulist
etcdctl set /haproxy/userlist/default-ulist/ulist_default       "group default-group users admin,haproxy"
etcdctl set /haproxy/userlist/ulist-fefault/user_admin          "user admin insecure-password admin"
#using encrypt password with python tool crypt with SHA-512
#python -c "import crypt, getpass, pwd; \
#             print crypt.crypt('password', '\$6\$adminadmin\$')"
etcdctl set /haproxy/userlist/ulist-default/user_haproxy        "user haproxy password $6$adminadmin$5dk1.UZjbA.3D1ZfMNmRForNFwa7kq/0Vkb04D.GwM2wa.Tw1c1T/T2ZHacara.6ujSipwf5RdGWHyWiyIAN21"


echo "...Peers(right now, only support one peers section)"

etcdctl set /haproxy/peers/$(hostname)                          "peer $(hostname) $COREOS_PRIVATE_IPV4:1024"

echo ".. Defaults(right now, only support one defaults section)"

#never set more than the limits (32768)
etcdctl set /haproxy/defaults/backlog                           "backlog 1024"
etcdctl set /haproxy/defaults/balance                           "balance roundrobin"
etcdctl set /haproxy/defaults/bind-process                      "bind-process all"
#etcdctl set /haproxy/defaults/cookie_<xxx>                     "cookie <xxx>  [ rewrite | insert | prefix ] [ indirect ] [ nocache ] [ postonly ] [ preserve ] [ domain <domain> ]* [ maxidle <idle> ] [ maxlife <life> ]"
#Change default options for a server in a backend
etcdctl set /haproxy/defaults/default-server                    "default-server inner 1000 weight 13"
etcdctl set /haproxy/defaults/default_backend                   "default_backend servers"
#etcdctl set /haproxy/defaults/disabled                         "disabled"
#etcdctl set /haproxy/defaults/enabled                          "enabled"

#can set multiple records for different error code HAProxy is capable of
#generating codes 200, 400, 403, 408, 500, 502, 503, and 504.
#etcdctl set /haproxy/defaults/errorfile_400                    "errorfile 400 /etc/haproxy/errorfiles/400badreq.http"
#etcdctl set /haproxy/defaults/errorfile_403                    "errorfile 400 /etc/haproxy/errorfiles/403badreq.http"
#can set multiple records for different error code  HAProxy is capable of
#generating codes 200, 400, 403, 408, 500, 502, 503, and 504.
#etcdctl set /haproxy/defaults/errorloc_400                     "errorloc 400 <url>"
#errorloc302, errorloc303 is the same as errorloc

#it is better not to set fullconn, grace
#etcdctl set /haproxy/defaults/fullconn                         "fullconn 10000"
#etcdctl set /haproxy/defaults/grace                            "grace 3s"
#etcdctl set /haproxy/defaults/hash-type                        "hash-type map-based"
#etcdctl set /haproxy/defaults/http-check_disable-on-404        "http-check disable-on-404"
#etcdctl set /haproxy/defaults/http-check_expect                "http-check expect [!] <match> <pattern>"
#etcdctl set /haproxy/defaults/http-check_send-state            "http-check send-state"
#etcdctl set /haproxy/defaults/http-send-name-header            "http-send-name-header  [<header>]"
etcdctl set /haproxy/defaults/log_global                        "log global"
#etcdctl set /haproxy/defaults/no_log                           "no log"
#can use multiple configuration for log
#etcdctl set /haproxy/defaults/log_<n>                          "log 127.0.0.1:514 local0 notice notice" 
etcdctl set /haproxy/defaults/maxconn                           "maxconn 1024" 
#the possible valueof mode is  tcp|http|health (health is deprecated)
etcdctl set /haproxy/defaults/mode                              "mode http"
#etcdctl set /haproxy/defaults/monitor-net                      "monitor-net 192.168.0.252/31"
etcdctl set /haproxy/defaults/monitor-uri                       "monitor-uri /haproxy_test"

#option xxxx to enable xxx, no option xxxx to disbale xxxx. don't use enable and disable at the same time
etcdctl set /haproxy/defaults/option_abortonclose               "option abortonclose"
#etcdctl set /haproxy/defaults/no_option_abortonclose           "no option abortonclose"
#etcdctl set /haproxy/defaults/option_accept-invalid-http-request "option accept-invalid-http-request"
#etcdctl set /haproxy/defaults/no_option_accept-invalid-http-request "no option accept-invalid-http-request"
#etcdctl set /haproxy/defaults/option_accept-invalid-http-response   "option accept-invalid-http-response"
#etcdctl set /haproxy/defaults/no_option_accept-invalid-http-response   "no option accept-invalid-http-response"
etcdctl set /haproxy/defaults/option_allbackups                 "option allbackups"
#etcdctl set /haproxy/defaults/no_option_allbackups             "no option allbackups"
etcdctl set /haproxy/defaults/option_checkcache                 "option checkcache"
#etcdctl set /haproxy/defaults/no_option_checkcache             "no option checkcache"
etcdctl set /haproxy/defaults/option_clitcpka                   "option clitcpka"
#etcdctl set /haproxy/defaults/no_option_clitcpka               "no option clitcpka"
#there is no "no option for option_contstats"
#etcdctl set /haproxy/defaults/option_contstats                 "option contstats"
#turn on this in production
#etcdctl set /haproxy/defaults/option_dontlog-normal            "option dontlog-normal"
etcdctl set /haproxy/defaults/no_option_dontlog-normal          "no option dontlog-normal"
#etcdctl set /haproxy/defaults/option_dontlognull               "option dontlognull"
#etcdctl set /haproxy/defaults/no_option_dontlognull            "no option dontlognull"

# This option implicitly enables the "httpclose" option
#etcdctl set /haproxy/defaults/option_forceclose                "option forceclose"
#etcdctl set /haproxy/defaults/no_option_forceclose             "no option forceclose"

#option forwardfor [ except <network> ] [ header <name> ] [ if-none ]
#etcdctl set /haproxy/defaults/option_forwardfor                "option forwardfor"

#etcdctl set /haproxy/defaults/option_http-no-delay             "option http-no-delay"
#etcdctl set /haproxy/defaults/no_option_http-no-delay          "no option http-no-delay"

#not to use it
#etcdctl set /haproxy/defaults/option_http-pretend-keepalive    "option http-pretend-keepalive"
#etcdctl set /haproxy/defaults/no_option_http-pretend-keepalive "no option http-pretend-keepalive"

#etcdctl set /haproxy/defaults/option_http-server-close         "option http-server-close"
#etcdctl set /haproxy/defaults/no_option_http-server-close      "no option http-server-close"
#etcdctl set /haproxy/defaults/option_http-use-proxy-header     "option http-use-proxy-header"
#etcdctl set /haproxy/defaults/no_option http-use-proxy-header  "no option http-use-proxy-header"

#only check tcp connect as default
#option httpchk
#option httpchk <uri>
#option httpchk <method> <uri>
#option httpchk <method> <uri> <version>
etcdctl set /haproxy/defaults/option_httpchk                    "option httpchk"

#etcdctl set /haproxy/defaults/option_httpclose                 "option httpclose"
#etcdctl set /haproxy/defaults/no_option_httpclose              "no option httpclose"
#etcdctl set /haproxy/defaults/option_httplog                   "option httplog [clf]"
#etcdctl set /haproxy/defaults/option_http_proxy                "option http_proxy"
#etcdctl set /haproxy/defaults/no_option_http_proxy             "no option http_proxy"
#etcdctl set /haproxy/defaults/
#etcdctl set /haproxy/defaults/







echo "init data for defaults section. only one default section is supported now"

