`ifndef IN_MON
   `define IN_MON
   `include "in_intf/in_mon.svp"
`endif

`ifndef OUT_MON
   `define OUT_MON
   `include "out_intf/out_mon.svp"
`endif

class pdm_mod_rec_c;
   time            timestamp;
   in_trans_rec_c  in_tr;
   out_trans_rec_c out_tr;

   // TO DO (Lab Step 8): Create a coverage group called pkt_cov.
   // ---> within this coverage group:
   // - Create a coverpoint called "dst_port" on dst_port in the in_tr, 
   //   with values 1-4 each in their own bin "port[x]" (use bins <name>[]),
   //   and value 0 and those above 4 ignored (ignore_bins).
   // - Create a coverpoint called "payload_size" on payload_size in
   //   the in_tr, with each valid value (4,8,12,16) in its own bin.
   // - Create a cross of the dst_port and payload_size coverpoints
   //   called dst_port_x_payload_sz.
   //
   // NOTE: Make sure to add the following line at the top of your covergroup
   // body, or else the coverage from each mod_rec will not be merged together
   // in the coverage viewer:
   // type_option.merge_instances = 1;
   covergroup pkt_cov;
      type_option.merge_instances = 1;

      dst_port: coverpoint in_tr.dst_port {
`protected

    MTI!#]v@s+1xA'E25v=1#p;*o9m7#@[=W7@\liY#u[N/"_ia[#Na}ps'zkRr#5x*+sI8?x$Uz!rl
    5po<EupC~}wOzQn[~]wVlTO[J}kTUw$TT7mG'*!*Y{]<1i2vh@p5n}>2>}3BR?<A'7lD$OnO]pZ]
    \i}i[$Tnn@a$-
`endprotected
      }

      payload_size: coverpoint in_tr.payload_size {
`protected

    MTI!#?xH=^YpUrr?ajeu71V{w7Bn-I,DIxI1j|QZDG="[2[U=Zj;2$]EjvSf{QQ25'2<[!z~?>s#
    DRei8]iD2Qm!kTskH!palrBGi!5w-qys\HTiX'n5W@T.NDJwQpUVoV[
`endprotected
      }

      dst_port_x_payload_sz: cross dst_port, payload_size;
   endgroup

   // TO DO (Lab Step 8): Create a coverage group called in_if_cov.
   // ---> within this coverage group:
   // - Create a coverpoint called "ack_delay" on ack_delay in the
   //   us_tr. Put values 1, 2, and 3 in individual bins called "low[x]",
   //   where "x" is an automatically assigned number (use bins <name>[]).
   //   Place values 4-8 together in one bin called "med", and capture
   //   all other values in a default bin called "high" (use "default" keyword).
   //
   // NOTE: Make sure to add the following line at the top of your covergroup
   // body, or else the coverage from each mod_rec will not be merged together
   // in the coverage viewer:
   // type_option.merge_instances = 1;
   covergroup in_if_cov;
      type_option.merge_instances = 1;

      ack_delay: coverpoint in_tr.ack_delay {
`protected

    MTI!#nh1pR]lQZkEK<!^Z<K;V=jLaI5+U}IEFl#[#|*~@m-sYUF#EnVTj<r*TzQE=;[-XzGjjx+v
    e;Gk,e,2rKJ>T<^,&yl5H}vua+I1!VkY\Oj+.H{sBl+K?w57uGHuEfm{Cu6nDriLIx3$^AQ#=ko7
    oCTpX$]
`endprotected
      }
   endgroup

   // TO DO (Lab Step 8): Create a coverage group called out_if_cov.
   // ---> within this coverage group:
   // - Create a coverpoint called "proceed_delay" on proceed_delay in
   // the ds_tr. Put values 1, 2, and 3 in individual bins called "low[x]",
   // where "x" is an automatically assigned number (use bins <name>[]).
   //   Place values 4-8 together in one bin called "med", and capture
   //   all other values in a default bin called "high" (use "default" keyword).
   //
   // NOTE: Make sure to add the following line at the top of your covergroup
   // body, or else the coverage from each mod_rec will not be merged together
   // in the coverage viewer:
   // type_option.merge_instances = 1;
   covergroup out_if_cov;
      type_option.merge_instances = 1;

      proceed_delay: coverpoint out_tr.proceed_delay {
`protected

    MTI!#lslQ}aBZR_}p+\=p3G~<$A=vQ~DH]QKx7~BQ*Ps35m+]s!}@wOn\;[M*7z,E};[-XzGjjx+
    ve;Gk,e,2rKJ>T<^,&yl5H}vua+I1!VkY\Oj+.H{sBl+K?w57uGHuEfm{Cu6nDriLIx3$^AQ#=ko
    7oCTpX$]
`endprotected
      }
   endgroup

   // TO DO (Lab Step 8): Create the class constructor function and
   // instantiate the above three coverage groups
`protected

    MTI!#D<j}o*WXz{ppIKVs$~^-Skp'=m{$@=2dhQGr["[W,o|13]Ip-~2$9z>j$|#}[KYmo+eW^UX
    U]vfp;_$mo$Jn\TvoO$CReQ^\YZJBez2'u>l]}}oY;EpIW+;z[=!&oYEDG?^2DJR2c(pZj$ZXse}
    !-1h1r~\Q<
`endprotected
endclass

class pdm_module_c;
   bit enabled = 0;

   pdm_mod_rec_c in_progress_pkts[$];
   pdm_mod_rec_c completed_pkts[$];

`protected

    MTI!#ja@Gr>o,Xp3H.2v?^;H;xcWIvZ-1BQ\ri=Iz1ih=IK[6m}@J'A,^ygemCsNJ[m~$maj}AQO
    e]DE~=5TAsR1#auo1l;QBIs*^I7z}+1#j#OW5?,YM2''O}K{5*v[m#B}uHQ9CUMI_i,Y7,rPOS-<
    }}[-=Dfx\Z7DXJYR*;[wr@-[mK{s[7[1a0\n1_u=7#-1VCIJ!$ECAZI~seT7<#TETTBmW}NEG[XN
    A*/h)l]B@I!>CH}B,\XG#,,$B2CoYKD#Xb"[Bl;B_!oW'#'YBAYG_j1?]+G>Ek_{}D[V<X5e3]W#
    sK7rDH[('Y-2qA>Ri-YCeHTD2BDX]R?D<k{RH[0f,W712^1iA=@G#,<}^2A7$YE}V2enE2,zwU@U
    XREY%Iz<2I$3YI;'GXU]<I[!Z#*Ow?-D=gBi_JG'+aRey[I2>O+7Q[6CYz;UrX\K*WV>TB}jD?k3
    X$Tkw1<zzBBSI4Tjux2TD^9*7+B=nss*ZIEBguXwV_<;AYNXB'QQACw}V5\+\.BX~[8ATR#1~>O&
    ,>viIBkBf',#AG2*$}ARDpslA'Co~WrHXDCUY6JX0|A}b=^5=e7EKTwno,3O7ddmY?X@sT!,m+o2
    s-;Z5~'BRG$&tHIiUj\skQAmEw{>DsrVj/25->~Ev,lTwI~TwBWa3o4B++O$Ir$x17]qXCZpUC;'
    xOUW8^ZasvC[^\Z$JiCBvIwBZ^_CvhJ=]CqzK<s*C1vh!}~;vKG_=Zzppw>!}O$GO>YTlC!oNOA>
    YQAB*a]i>|-1D'dJw=Cr;lr5Djn}@psjU3JCT3173$iT\D}nIClusa}o'A\#BJ7rw5E[oI_$}kK5
    Yskem~{/{{!2}j!G5~u>[ep*/(#w=Kvw]^pXH;EHQ=BR7{<'!K*OK$zUTx[j3r_jr'WB7-e?r*'H
    ZTC5K~x-~'7iCVG3KQzQ$e'^Y~;5!<-oU^{*}rrnZ?|nC#Q<=Onu}WVr}5D(x#-~7u'$oT$3z[Di
    Pd+][@,&^#A\rvrv/H6l>e*W5AV}Ha,OlC~l,DHG!G$2j-Kphzns-QZzQGB,2T<^=L_XG!+-@+>z
    n'7z+rnn5*$~Dss!*;p:)|q}@EXJ_K5OpQ[^CGU*=,GWlX'A_1HO?uRr~]'[i+a1nr{zxBI>QX_h
    k6kv?o\{VV,,J;me{C_[IXl@XD|X,#!h74D[\Ype\IWTxJq7{oK%}p2!~<*@$sRZ'zB]Kvl'N/3>
    Z\rpWsGs^AL|V*k=!Tx@RUd+TsO,*@$k}V_f_Q}@gJ<,BFFr1lTaG=jyqkQenHIZ#o!BBoarJa][
    =#,*oB;Xoa$*{rrXsk7@ak7B^G[[J*D-ssE7kC5KwrTJ=j^GsXCQ3*eB7YEi[9jA[i[wz}#-=IY<
    *7W>BU9CvoTT=es=vAwR}7;E^arL13l{p*;I~-3ORkJ}h5bZ=7;{U~1ueoaG]~16,xn}z2;eQ;Y'
    Y:A>o$>z!34a<H?q=]E*C3~+C3ZJzVjEEAplIKTTB]X?5[R]x-<psu{#/>ri]Ae!E2p[['n{vVeC
    HoZAofsu5o,K;GuTn=wU]@;j{#^3uerWos*Uu2fD-7?InXK8W[5aW1w,5{|'&jlXKXYIr!D?#7-\
    '_uj*;C+15}T=Q+<]~jD[0'ITH[h5C$;s#@5qA=XC&mOQ*D-oVCVi<cpA&+w-~2l^=Y!!R'<KrZT
    x<k]AO~oB[(9<H$Z>v*]K6V-A]s<2s{[U}:sr=J=ep=oH{HND--*p#J+-LfeHn@Gk>?^_E<j=3H+
    C2aiQRGu{60,s{#D*RiBHH]5HQu{5mCRYv,nlU\e#I3C]JG<'vDX<W*ZplO9#5Bj*,,}#R?ar,'#
    eG]rp~]zl'?]']cOjn2E41oXop?evB+\*VXjkdm[-p2R5[js#wv=U]Y'Ar[k5]o\\K(#[W{Po=Hr
    hO5ZYY+J!l;}$OoQC+G1{_R+a3T1_;Rs~<IC_KUJr*U]oeG,ext-5U<b8&tTOn>rKjU]Dw#1g}je
    >2>x{;p!!@B,n;B>ORix_jIiplu{j-nHl^W5$3[35?eG1*+1K2$J_Dw*HIHRwasDC$vuo@j2Z%QU
    \~7n!rBX+Z=C7T/<$s}}{+#}D?kIeHYJ{J]M}!'eK$nIgU{>ATs;\Yjn!FYxXEY,7U,3Yr1jg}~I
    2w*mQZ[
`endprotected
endclass

